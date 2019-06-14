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

# Reference model typeahead test.
class RefARTA4AuthorIdWithStringMatching2Authors < ActiveSupport::TestCase
  test "id with string matching 2 authors" do
    skip
    # This test became redundant in its present form when a
    # database constraint was added to prevent duplicate author names.
    # I'm leaving it here so when we clean it out we review the code
    # than handles this case in the typeahead - needs refactoring,
    # possibly different type of testing.
    author_1 = authors(:has_matching_name_1)
    author_2 = authors(:has_matching_name_2)
    result = Reference::AsEdited.author_from_typeahead(
      author_2.id.to_s,
      author_1.name
    )
    assert_equal author_2.id,
                 result,
                 "Should get a match for the correct id"
  end
end
