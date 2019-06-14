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

# Test authorisations for a Reader viewing Names
class NameReaderOnlyDetailsTab < ActionController::TestCase
  tests NamesController
  setup do
    @name = names(:a_species)
  end

  test "should not show reader the edit tab" do
    @request.headers["Accept"] = "application/javascript"
    get(:show,
        { id: @name.id, tab: "tab_edit" },
        username: "fred",
        user_full_name: "Fred Jones",
        groups: [])
    assert_response :forbidden
  end

  setup do
    @name = names(:a_species)
  end

  test "reader should see only details tab link" do
    @request.headers["Accept"] = "application/javascript"
    get(:show,
        { id: @name.id, tab: "tab_details" },
        username: "fred",
        user_full_name: "Fred Jones",
        groups: [])
    assert_response :success
    assert_select "a#name-details-tab", true, "Should show 'Detail' tab."
    assert_select "a#name-edit-tab", false, "Should not show 'Edit' tab."
    assert_select "a#name-instances-tab",
                  false,
                  "Should not show 'Instance' tab."
    assert_select "a#name-more-tab", false, "Should not show 'More' tab."
  end
end
