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
class Name::AsEdited < Name::AsTypeahead
  include NameAuthorResolvable
  include NameParentResolvable
  include NameFamilyResolvable
  include NameDuplicateOfResolvable

  def self.create(params, typeahead_params, username)
    name = Name::AsEdited.new(params)
    name.resolve_typeahead_params(typeahead_params)
    if name.parent
      name.name_path = name.parent.name_path + '/' + name.name_element
    else
      name.name_path = name.name_element
    end
    if name.save_with_username(username)
      name.set_names!
    else
      raise name.errors.full_messages.first.to_s
    end
    name
  end

  def update_if_changed(params, typeahead_params, username)
    params["verbatim_rank"] = nil if params["verbatim_rank"] == ""
    assign_attributes(params)
    resolve_typeahead_params(typeahead_params)
    save_updates_if_changed(username)
  end

  def save_updates_if_changed(username)
    if changed?
      self.updated_by = username
      save!
      set_names!
      "Updated"
    else
      "No change"
    end
  end

  def resolve_typeahead_params(params)
    resolve_author(params, "author")
    resolve_author(params, "ex_author")
    resolve_author(params, "base_author")
    resolve_author(params, "ex_base_author")
    resolve_author(params, "sanctioning_author")
    resolve_parent(params, "parent")
    resolve_parent(params, "second_parent")
    resolve_family(params, "family")
    resolve_duplicate_of(params)
  end
end
