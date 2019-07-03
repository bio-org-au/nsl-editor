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

# Single Search model test.
class SearchOnAuthorIdMultipleTest < ActiveSupport::TestCase
  test "search on author id multiple" do
    author = authors(:haeckel)
    a2 = authors(:brongn)
    params = ActiveSupport::HashWithIndifferentAccess.new(
      query_target: "author",
      query_string: "id: #{author.id}, #{a2.id}",
      include_common_and_cultivar_session: true,
      current_user: build_edit_user
    )
    search = Search::Base.new(params)
    assert_equal 2,
                 search.executed_query.results.size,
                 "Exactly 2 results expected for author id search for 2 ids."
  end
end
