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
class OverrideQueryOnViaSearchFieldRefTest < ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  test "reference search for Nuytsia 2015 with embedded percent signs" do
    visit_home_page
    standard_page_assertions
    select "Author", from: "query-on"
    fill_in "search-field", with: "ref:%Nuytsia%2015%"
    click_button "Search"
    sleep(0.1)
    search_result_must_include_content("Telford")
    search_result_must_include_content("Telford, I.R.H. & Naaykens, J.,")
    string = "(2015) Synostemon hamersleyensis (Phyllanthaceae),
    a new species endemic to the Pilbara, Western Australia.
    Nuytsia. 25 : 31-37 "
    search_result_must_include_content(string)
  end
end
