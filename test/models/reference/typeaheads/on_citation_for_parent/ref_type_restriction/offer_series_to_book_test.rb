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

# Reference model typeahead search.
class TAOnCit4ParentRefTypeRestrictionSeriesForBook < ActiveSupport::TestCase
  test "reference typeahead on citation ref type restriction series for book" do
    current_reference = references(:simple)
    typeahead = Reference::AsTypeahead::OnCitationForParent.new(
      "%",
      current_reference.id,
      ref_types(:book).id
    )
    assert_not typeahead.results.empty?, "Should be at least one result"
    series = 0
    others = 0
    typeahead.results.each do |result|
      if result[:value] =~ /\[series\]/
        series += 1
      else
        others += 1
      end
    end
    assert others.zero?, "Expecting no other ref types."
    assert series.positive?, "Expecting at least 1 series ref type."
  end
end
