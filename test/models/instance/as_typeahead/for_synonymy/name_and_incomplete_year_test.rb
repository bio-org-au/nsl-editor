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
require "models/instance/as_typeahead/for_synonymy/test_helper.rb"

# Single instance typeahead search.
class ForNameAndReferenceYearTest < ActiveSupport::TestCase
  def setup
    @typeahead = Instance::AsTypeahead::ForSynonymy.new("angophora costata 178",
                                                        names(:a_species).id)
  end

  test "name and incomplete year search" do
    assert @typeahead.results.class == Array, "Results should be an array."
    assert @typeahead.results.size >= 2, "Incomplete year should be ignored."
    assert @typeahead.results
                     .collect { |r| r[:value] }
      .include?(ANGOPHORA_COSTATA_DE_FRUCT_1788_STRING),
           ANGOPHORA_COSTATA_DE_FRUCT_1788_ERROR
    assert @typeahead.results
                     .collect { |r| r[:value] }
      .include?(ANGOPHORA_COSTATA_JOURNAL_1916_STRING),
           ANGOPHORA_COSTATA_JOURNAL_1916_ERROR
  end
end
