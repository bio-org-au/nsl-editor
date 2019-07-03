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

# Single name model test.
class NameAsResolvTA4DupeOfIdWStrMatchingTwoNamesTest < ActiveSupport::TestCase
  test "no dupe of id with string matching 2 names" do
    name_1 = names(:name_matches_another_1)
    assert_equal 2,
                 Name.where(full_name: name_1.full_name).size,
                 "Should be two Names with the same full name string."
    assert_raise(RuntimeError,
                 "Should raise a RuntimeError for invalid author string.") do
      Name::AsResolvedTypeahead::ForDuplicateOf.new("", name_1.full_name)
    end
  end
end
