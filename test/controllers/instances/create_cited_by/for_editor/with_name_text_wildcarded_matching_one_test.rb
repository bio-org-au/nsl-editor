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
require "test_helper"

# Single controller test.
class InstCreCitedByWNameWildcardedTextMatch1Test < ActionController::TestCase
  tests InstancesController
  def setup
    @cited_by = instances(:gaertner_created_metrosideros_costata)
    @request.headers["Accept"] = "application/javascript"
  end

  test "create unpub citation typeahead match with wildcard" do
    assert_no_difference("Instance.count") do
      post(:create_cited_by,
           { instance: { "name_typeahead" => "argyle app",
                         "name_id" => "",
                         "page" => "",
                         "reference_id" => @cited_by.reference.id,
                         "cited_by_id" => @cited_by.id,
                         "cites_id" => "",
                         "instance_type_id" => instance_types(:common_name) } },
           username: "fred", user_full_name: "Fred Jones", groups: ["edit"])
    end
  end
end
