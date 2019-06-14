#   encoding: utf-8

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

# encoding: utf-8
require "test_helper"

# Single integration test.
class AvailableFieldsForOrdinaryEditorTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  test "Ordinary Editor gets the right fields" do
    visit_home_page_as_editor
    standard_page_assertions
    select "Instances", from: "query-on"
    select "with id", from: "query-field"
    fill_in "search-field",
            with: instances(:britten_created_angophora_costata).id
    click_on "Search"
    little_sleep
    all(".takes-focus").first.click
    click_on "instance-edit-tab"
    little_sleep
    search_result_details_must_not_include_field("instance-reference-typeahead",
                                                 "Ref typeahead shouldnt
                                                 be there")
    search_result_details_must_include_field("instance_page",
                                             "Instance page field should be
                                             there")
    search_result_details_must_include_field("instance_instance_type_id",
                                             "Instance type select field
                                             should be there")
    search_result_details_must_include_field("instance_verbatim_name_string",
                                             "Instance verbatim name string
                                             field should be there")
    search_result_details_must_include_field("instance_bhl_url",
                                             "Instance BHL URL string field
                                             should be there")
  end
end
