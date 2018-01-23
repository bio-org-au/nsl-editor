# frozen_string_literal: true

#   Copyright 2015 Australian National Botanic Gardens
#
#   This file is part of the NSL Editor.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

#   Trees are classification graphs for taxa.
#   There are several types of trees - see the model.
class TreesController < ApplicationController
  def index;
  end

  def ng
    render "trees/#{params[:template]}", layout: false
  end

  # Move an existing taxon (inc children) under a different parent
  def replace_placement
    logger.info("In replace placement!")
    target = TreeVersionElement.find(move_name_params[:element_link])
    parent = TreeVersionElement.find(move_name_params[:parent_element_link])

    profile = Tree::ProfileData.new(current_user, target.tree_version, {})
    profile.update_comment(move_name_params[:comment])
    profile.update_distribution(move_name_params[:distribution])

    replacement = Tree::Workspace::Replacement.new(username: current_user.username,
                                                   target: target,
                                                   parent: parent,
                                                   instance_id: move_name_params[:instance_id],
                                                   excluded: move_name_params[:excluded],
                                                   profile: profile.profile_data)
    response = replacement.replace
    @html_out = process_problems(replacement_json_result(response))
    render "moved_placement.js"
  rescue RestClient::Unauthorized, RestClient::Forbidden => e
    @message = json_error(e)
    render "move_placement_error.js"
  rescue RestClient::ExceptionWithResponse => e
    @message = json_error(e)
    render "move_placement_error.js"
  end

  # Place and instance on the draft tree version
  def place_name
    excluded = place_name_params[:excluded] ? true : false
    parent_element_link = place_name_params[:parent_name_typeahead_string].blank? ? nil : place_name_params[:parent_element_link]
    tree_version = TreeVersion.find(place_name_params[:version_id])

    profile = Tree::ProfileData.new(current_user, tree_version, {})
    profile.update_comment(place_name_params[:comment])
    profile.update_distribution(place_name_params[:distribution])

    placement = Tree::Workspace::Placement.new(username: current_user.username,
                                               parent_element_link: parent_element_link,
                                               instance_id: place_name_params[:instance_id],
                                               excluded: excluded,
                                               profile: profile.profile_data,
                                               version_id: place_name_params[:version_id])
    response = placement.place
    @message = placement_json_result(response)
    render "place_name.js"
  rescue RestClient::Unauthorized, RestClient::Forbidden => e
    @message = json_error(e)
    render "place_name_error.js"
  rescue RestClient::ExceptionWithResponse => e
    @message = json_error(e)
    render "place_name_error.js"
  end

  def remove_name_placement
    target = TreeVersionElement.find(remove_name_placement_params[:taxon_uri])
    removement = Tree::Workspace::Removement.new(username: current_user.username,
                                                 target: target)
    response = removement.remove
    @message = json_result(response)
    render "removed_placement.js"
  rescue RestClient::Unauthorized, RestClient::Forbidden => e
    @message = json_error(e)
    render "remove_placement_error.js"
  rescue RestClient::ExceptionWithResponse => e
    @message = json_error(e)
    render "remove_placement_error.js"
  end

  def update_comment
    logger.info "update comment #{params[:pk]} #{params[:value]}"
    tve = TreeVersionElement.find(params[:pk])
    profile_data = Tree::ProfileData.new(current_user, tve.tree_version, tve.tree_element.profile || {})
    profile_data.update_comment(params[:value])
    profile = Tree::Workspace::Profile.new(username: current_user.username,
                                           element_link: tve.element_link,
                                           profile_data: profile_data)
    profile.update

  rescue RestClient::Unauthorized, RestClient::Forbidden, RestClient::ExceptionWithResponse => e
    @message = json_error(e)
    render :text => @message, :status => 401
  end

  def update_distribution
    logger.info "update distribution #{params[:pk]} #{params[:value]}"
    tve = TreeVersionElement.find(params[:pk])
    profile_data = Tree::ProfileData.new(current_user, tve.tree_version, tve.tree_element.profile || {})
    profile_data.update_distribution(params[:value])
    profile = Tree::Workspace::Profile.new(username: current_user.username,
                                           element_link: tve.element_link,
                                           profile_data: profile_data)
    profile.update

  rescue RestClient::Unauthorized, RestClient::Forbidden, RestClient::ExceptionWithResponse => e
    @message = json_error(e)
    render :text => @message, :status => 401
  end

  def update_excluded
    logger.info "update excluded #{params[:taxonUri]} #{params[:excluded]}"
    Tree::Workspace::Excluded.new(username: current_user.username,
                                  element_link: params[:taxonUri],
                                  excluded: params[:excluded]).update
  rescue RestClient::Unauthorized, RestClient::Forbidden, RestClient::ExceptionWithResponse => e
    @message = json_error(e)
    render :text => @message, :status => 401
  end

  private

  # todo determine if this should be removed.
  # def minor_update_profile(tve, key)
  #   data = tve.tree_element.profile
  #   current_key_data = data[key]
  #   data[key] = { value: params[:value],
  #                 updated_by: current_user.username,
  #                 updated_at: Time.now.utc.iso8601,
  #                 previous: current_key_data }
  #   Tree::Workspace::Profile.new(username: current_user.username,
  #                                element_link: tve.element_link,
  #                                profile_data: data)
  # end

  def json_error(err)
    logger.error(err)
    json = JSON.parse(err.http_body, object_class: OpenStruct)
    if json&.error
      logger.error(json.error)
      json.error
    else
      json&.to_s || err.to_s
    end
  rescue
    err.to_s
  end

  def json_result(result)
    json = JSON.parse(result.body, object_class: OpenStruct)
    json&.payload&.message || result.to_s
  rescue
    result.to_s
  end

  def placement_json_result(result)
    json = JSON.parse(result.body, object_class: OpenStruct)
    json&.payload&.message || result.to_s
  rescue
    result.to_s
  end

  def replacement_json_result(result)
    JSON.parse(result.body)['payload']
  rescue
    result.to_s
  end

  def process_problems(payload)
    payload['problems']
  end

  def list_problems(key, problems)
    return '' if problems.nil? || problems.empty?
    "<strong>#{key}:</strong><ul><li>" +
        problems.join("</li><li>") +
        "</li></ul>"
  end

  def move_name_params
    params.require(:move_placement)
        .permit(:element_link,
                :parent_element_link,
                :instance_id,
                :comment,
                :distribution,
                :excluded)
  end

  def place_name_params
    params.require(:place_name)
        .permit(:name_id,
                :instance_id,
                :parent_element_link,
                :comment,
                :distribution,
                :excluded,
                :version_id,
                :parent_name_typeahead_string)
  end

  def remove_name_placement_params
    params.require(:remove_placement).permit(:taxon_uri, :delete)
  end

  def comment_params
  end


end
