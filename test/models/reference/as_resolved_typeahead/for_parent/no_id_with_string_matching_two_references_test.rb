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

# Reference model parent from typeahead test.
class RefAsEdNoParIdWthStringMatchingTwoReferencesTest < ActiveSupport::TestCase
  test "no id with invalid string" do
    reference_1 = references(:has_a_matching_citation_1)
    assert_equal 2,
                 Reference.where(citation: reference_1.citation).size,
                 "Should be two References with the same citation string."
    assert_raise(RuntimeError,
                 "Should raise a RuntimeError for invalid reference string.") do
      Reference::AsResolvedTypeahead::ForParent.new("", reference_1.citation)
    end
  end
end
