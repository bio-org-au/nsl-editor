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

require "test_helper"

# Single integration test.
class BaseAuthorIdTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  test "name search option base author id" do
    visit_home_page
    select "Name", from: "query-on"
    select "base author id", from: "query-field"
    assert find("#query-field").value == "ba-id",
           "Base Author ID key should be in use."
  end
end
