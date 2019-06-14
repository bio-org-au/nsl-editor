#   encoding: utf-8

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

# Single author model test.
class AuthorAsTheadOnAbbrevOUmlautFindsOAndOUmlautTest < ActiveSupport::TestCase
  test "author o finds o and o umlaut test" do
    results = Author::AsTypeahead.on_abbrev("Döll")
    assert_equal 2, results.size, "Expecting 2 record for 'Döll'."
    ids = results.collect { |author| author[:id] }
    assert ids.include?(authors(:doll_no_umlaut).id.to_s),
           "Expecting doll_no_umlaut"
    assert ids.include?(authors(:doll_with_umlaut).id.to_s),
           "Expecting doll_with_umlaut"
  end
end
