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
class CultivarParMustAllowNamesWithoutAnInstanceTest < ActiveSupport::TestCase
  test "name cultivar parent suggestions allows names without an instance" do
    name = Name.find_by(full_name: "a species without an instance")
    assert name.present?,
           'Target name "a species without an instance" should be found'
    assert name.instances.size.zero?,
           "The name 'a species without an instance' should have no instances."
    suggestions = Name::AsTypeahead.cultivar_parent_suggestions(
      "a species without an instance", -1
    )
    assert(suggestions.is_a?(Array), "suggestions should be an array")
    assert(suggestions.size == 1,
           'Suggns for "a species without an instance" shld have 1 element')
    assert(suggestions.first[:value].match(/a species without an instance/),
           "Suggestions should include 'a species without an instance'.")
  end
end
