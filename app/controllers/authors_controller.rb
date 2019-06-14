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
#
class AuthorsController < ApplicationController
  before_filter :find_author, only: [:show, :destroy, :tab]

  # GET /authors/1
  # GET /authors/1/tab/:tab
  # Sets up RHS details panel on the search results page.
  # Displays a specified or default tab.
  def show
    set_tab
    set_tab_index
    render "show", layout: false
  end

  alias tab show

  # GET /authors/new_row
  def new_row
    @random_id = (Random.new.rand * 10_000_000_000).to_i
    respond_to do |format|
      format.html { redirect_to new_search_path }
      format.js {}
    end
  end

  # GET /authors/new
  def new
    @author = Author.new
    @no_search_result_details = true
    @tab_index = (params[:tabIndex] || "40").to_i
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end

  # POST /authors
  def create
    @author = Author::AsEdited.create(author_params,
                                      typeahead_params,
                                      current_user.username)
    render "create.js"
  rescue => e
    logger.error("Controller:Authors:create:rescuing exception #{e}")
    @error = e.to_s
    render "create_error.js", status: :unprocessable_entity
  end

  def update
    @author = Author::AsEdited.find(params[:id])
    @message = @author.update_if_changed(author_params,
                                         typeahead_params,
                                         current_user.username)
    render "update.js"
  rescue => e
    logger.error("Author#update rescuing #{e}")
    @message = e.to_s
    render "update_error.js", status: :unprocessable_entity
  end

  # DELETE /authors/1
  # DELETE /authors/1.json
  def destroy
    username = current_user.username
    if @author.update_attribute(:updated_by, username) && @author.destroy
      render
    else
      render js: "alert('Could not delete that record.');"
    end
  end

  # Columns such as parent and duplicate_of_id use a typeahead search.
  def typeahead_on_name
    if params[:term].blank?
      render json: []
    else
      render json: Author::AsTypeahead.on_name(params[:term])
    end
  end

  # Columns such as parent and duplicate_of_id use a typeahead search.
  def typeahead_on_name_duplicate_of_current
    authors = []
    typeahead = Author::AsTypeahead
    unless params[:term].blank?
      authors = typeahead.on_name_duplicate_of(params[:term], params[:id])
    end
    render json: authors
  end

  # Columns such as parent and duplicate_of_id use a typeahead search.
  def typeahead_on_abbrev
    authors = []
    typeahead = Author::AsTypeahead
    authors = typeahead.on_abbrev(params[:term]) unless params[:term].blank?
    render json: authors
  end

  private

  def find_author
    @author = Author.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "We could not find the author."
    redirect_to authors_path
  end

  def author_params
    params.require(:author).permit(:name, :full_name, :abbrev, :notes)
  end

  def typeahead_params
    params.require(:author).permit(:duplicate_of_id, :duplicate_of_typeahead)
  end

  def set_tab
    @tab = if params[:tab].present? && params[:tab] != "undefined"
             params[:tab]
           else
             "tab_show_1"
           end
  end

  def set_tab_index
    @tab_index = (params[:tabIndex] || "1").to_i
  end
end
