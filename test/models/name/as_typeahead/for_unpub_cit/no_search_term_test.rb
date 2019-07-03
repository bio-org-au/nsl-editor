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
class NameTAForUCitNoSearchTermTest < ActiveSupport::TestCase
  test "name typeahead for unput cit no search term" do
    suggestions = Name::AsTypeahead::ForUnpubCit.new({}).suggestions
    assert(suggestions.is_a?(Array), "suggestions should be an array")
    assert_equal suggestions.size,
                 0,
                 "suggestions for no search term should be empty"
  end
end
