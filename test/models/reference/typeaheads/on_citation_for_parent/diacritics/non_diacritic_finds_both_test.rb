# frozen_string_literal: true
#
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

# Single reference model test.
class RefTypeAhOnCit4ParentNonDiacriticFindsBothTest < ActiveSupport::TestCase
  test "ref typeahead on citation for parent non diacritic finds both" do
    curr_ref = references(:ref_type_is_chapter)
    typeahead = Reference::AsTypeahead::OnCitationForParent.new(
      "Hilten",
      curr_ref.id,
      ref_types(:chapter).id
    )
    assert_equal 2,
                 typeahead.results.length,
                 "Expecting 2 records for 'Hilten'."
    ids = typeahead.results.collect { |reference| reference[:id] }
    assert ids.include?(references(:hilten_with_diacritic).id.to_s),
           "Expecting hilten_with_diacritic"
    assert ids.include?(references(:hilten_without_diacritic).id.to_s),
           "Expecting hilten_without_diacritic"
  end
end
