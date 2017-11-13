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
class Tree::Workspace::Movement < ActiveType::Object
  attribute :target, :TreeVersionElement
  attribute :parent, :TreeVersionElement
  attribute :username, :string

  validates :target, presence: true
  validates :parent, presence: true

  def move
    url = build_url
    payload = {taxonUri: target.element_link, newParentTaxonUri: parent.element_link}
    logger.info "Calling #{url}"
    raise errors.full_messages.first unless valid?
    RestClient.put(url, payload.to_json,
                   {content_type: :json, accept: :json})
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error("Tree::Workspace::Movement error: #{e}")
    raise
  rescue => e
    Rails.logger.error("Tree::Workspace::Movement other error: #{e}")
    raise
  end


  def build_url
    Tree::AsServices.move_placement_url(username)
  end

end
