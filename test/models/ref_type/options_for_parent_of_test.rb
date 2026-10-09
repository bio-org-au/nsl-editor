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

# The ref type options offered for a reference that has children. Only the
# first child's ref type is considered.
class RefTypeOptionsForParentOfTest < ActiveSupport::TestCase
  test "prefers the parent type of a child that has one" do
    assert_equal RefType.options_with_preference("Book"),
                 RefType.options_for_parent_of([ ref_types(:chapter) ])
  end

  test "offers the plain options for a child with no parent type" do
    assert_equal RefType.options,
                 RefType.options_for_parent_of([ ref_types(:database) ])
  end

  test "only the first child's ref type is considered" do
    assert_equal RefType.options,
                 RefType.options_for_parent_of([ ref_types(:database), ref_types(:chapter) ])
    assert_equal RefType.options_with_preference("Book"),
                 RefType.options_for_parent_of([ ref_types(:chapter), ref_types(:database) ])
  end

  test "duplicate child ref types give the same result as one" do
    assert_equal RefType.options_for_parent_of([ ref_types(:chapter) ]),
                 RefType.options_for_parent_of([ ref_types(:chapter), ref_types(:chapter) ])
  end
end
