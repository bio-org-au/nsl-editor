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

# Single author model test.
class AuthorWithNameButNoAbbrevIsValidTest < ActiveSupport::TestCase
  test "author with name but no abbrev valid test" do
    author = Author.new
    assert_not author.valid?, "New author should be invalid"
    assert_match(/Name can't be blank if abbrev is blank/,
                 author.errors.full_messages.join(";"),
                 "Error should mention blank name")
    assert_match(/Abbrev can't be blank if name is blank/,
                 author.errors.full_messages.join(";"),
                 "Error should mention blank abbrev")
    author.name = "wilma ismyname"
    assert author.valid?,
           "Author should be valid with a name even if no abbrev. \
  Errors: #{author.errors.full_messages.join('; ')}"
  end
end
