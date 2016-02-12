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
require "models/name/as_typeahead/name_parent/name_parent_test_helper"

# Single Name typeahead test.
class NameParentSubgenusIsOfferedForUnrankedTest < ActiveSupport::TestCase
  test "name parent suggestion for unranked include subgenus" do
    typeahead = Name::AsTypeahead::ForParent.new(
      term: "a_subgenus",
      avoid_id: 1,
      rank_id: NameRank.find_by(name: "[unranked]").id)
    expected_ranks = %w(Subgenus)
    suggestions_should_only_include(
      typeahead.suggestions, "[unranked]", expected_ranks)
  end
end
