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
load "test/models/search/users.rb"
load "test/models/search/on_name/test_helper.rb"

# Single Search model test.
class SearchOnNameAcceptedTreeNotInTest < ActiveSupport::TestCase
  test "search names not in the accepted tree" do
    params = ActiveSupport::HashWithIndifferentAccess.new(
      query_target: "name",
      query_string: "angophora not-in-accepted-tree:",
      current_user: build_edit_user
    )
    search = Search::Base.new(params)
    confirm_results_class(search.executed_query.results)
    # Just make sure the search runs i.e. view exists, rule exists
    assert search.executed_query.results.size > -1,
           "Expected > -1 search result for angophora"
  end
end
