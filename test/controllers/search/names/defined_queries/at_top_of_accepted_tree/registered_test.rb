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

# Single search controller test.
class NamesSearchDefinedAtTopOfAcceptedTreeRegTest < ActionController::TestCase
  tests SearchController

  test "search names at top of accepted tree is registered" do
    get(:search,
        { query_target: "Names",
          query_string: "at-top-of-accepted-tree:" },
        username: "fred",
        user_full_name: "Fred Jones",
        groups: [])
    assert_response :success
    assert_select "#search-results-summary",
                  /Names.*at-top-of-accepted-tree:/,
                  "Report should be recognised"
    assert_select "#search-results-summary" do |summary|
      summary.each do |s|
        assert_no_match(/Cannot search name for: at-top-of-accepted-tree:/,
                        s.to_s)
      end
    end
  end
end
