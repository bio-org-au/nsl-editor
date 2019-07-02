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

# Single Reference model test.
class RefValYearPersCommMustHaveYearTest < ActiveSupport::TestCase
  def setup
    @reference = references(:ref_type_is_personal_communication)
    @reference.iso_publication_date = 2000
  end

  test "ref of type personal communication must have a date" do
    assert @reference.valid?, "Should start out valid"
    @reference.iso_publication_date = ""
    assert_not @reference.valid?,
               "Personal comm. should be invalid without date"
    assert @reference.errors.full_messages
                     .include?("Iso publication date is required")
  end
end
