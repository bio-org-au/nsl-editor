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

# Single Search model test for Instance target.
class SearchOnInstanceHasNoAdnotTest < ActiveSupport::TestCase
  test "search for instances without adnot" do
    params =  ActiveSupport::HashWithIndifferentAccess
              .new(query_target: "instance",
                   query_string: "adnot: ",
                   include_common_and_cultivar_session: true,
                   current_user: build_edit_user)
    search = Search::Base.new(params)
    assert_equal Instance::ActiveRecord_Relation,
                 search.executed_query.results.class,
                 "Results should be a Instance::ActiveRecord_Relation."
    assert !search.executed_query.results.empty?, "Results expected."
    search.executed_query.results.each do |r|
      assert_equal 0, r.comments.size, "Should be no adnot (comments)"
    end
  end
end
