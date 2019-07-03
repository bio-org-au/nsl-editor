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
class Search4NameTypeNRankWildcardTypeThenRankTest < ActionController::TestCase
  tests SearchController

  test "editor search for name type and rank wildcard type then rank test" do
    get(:search,
        { query_target: "name",
          "query_string" => "nt:* nr:*",
          "controller" => "new_search",
          "action" => "search" },
        username: "fred",
        user_full_name: "Fred Jones",
        groups: ["edit"])
    assert_response :success
    assert_select "span#search-results-summary", true, "Should have summary "
    assert_select "span#search-results-summary",
                  /100 names of [0-9]+/,
                  "Summary should say names found"
  end
end
