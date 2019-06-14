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
class AuthorCannotLoseAbbrevIfNamesBaseAuthorTest < ActiveSupport::TestCase
  test "author cannot lose abbrev if names attached to base author" do
    author = authors(:has_base_authored_one_name_that_is_all)
    assert author.valid?, "Author should start out valid"
    assert !author.base_names.empty?,
           "Author should have at least one base attached"
    assert author.abbrev.present?, "Author should start with an abbreviation."
    author.abbrev = ""
    assert_not author.valid?,
               "Author with base names should not be valid without an abbrev"
  end
end
