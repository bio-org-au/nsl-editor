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
class InstanceTypesControllerForReaderSimpleTest < ActionController::TestCase
  tests InstanceTypesController

  test "reader should get index with correct elements" do
    get(:index, {}, username: "fred", user_full_name: "Fred Jones", groups: [])
    assert_response :success
    # assert_select 'a#new-dropdown-menu-link.dropdown-toggle',
    #               false,
    #               "Should not see New menu link."
    # assert_select 'a#help-dropdown-menu-link.dropdown-toggle',
    #               /Help/,
    #               "Should show Help menu link."
    # assert_select 'a#user-dropdown-menu-link.dropdown-toggle',
    #               true,
    #               "Should show User menu link."
    # assert_select 'a#admin-dropdown-menu-link.dropdown-toggle',
    #               false,
    #               "Should not show Admin menu link."
  end
end
