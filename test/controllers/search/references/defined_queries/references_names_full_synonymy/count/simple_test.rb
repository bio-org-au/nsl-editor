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
class SearchRefsDefinedQRefsNamesFullSynCountTest < ActionController::TestCase
  tests SearchController
  setup do
    @ref = references(:bucket_reference_for_default_instances)
  end

  test "count references names full synonymy" do

    get(:search,
        { query_target: "References, names, full synonymy",
          query_string: "count b*",
          query_submit: "Search"},
        username: "fred",
        user_full_name: "Fred Jones",
        groups: [])
    assert_response :success
    assert_select "#search-results-summary",
                  /[0-9][0-9] records\b/,
                  "Should find some records"
  end
end
