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

# Single Name typeahead test.
class ShouldIncludeAZeroInstancesCount < ActiveSupport::TestCase
  test "name parent suggestions should include a zero instances count" do
    dummy_avoid_id = 1
    name = Name.find_by(full_name: "a genus without an instance")
    assert name.present?,
           'The name "a genus without an instance" should be found.'
    assert name.instances.size.zero?,
           "The name 'a genus without an instance' should have no instances."
    typeahead =
      Name::AsTypeahead::ForParent.new(term: "a genus without an instance",
                                       avoid_id: dummy_avoid_id,
                                       rank_id: NameRank.species.id)
    assert(typeahead.suggestions.is_a?(Array), "suggestions should be an array")
    assert(typeahead.suggestions.size == 1,
           'suggestions for "a genus without an instance" should have a record')
    assert_match "genus without an instance | Genus | legitimate | 0 instances",
                 typeahead.suggestions.first[:value],
                 "Name par typeahead needs right val with a 0 instances count"
  end
end
