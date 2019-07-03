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
class AuthorNotSelectedFromTypeahead < ActiveSupport::TestCase
  test "create reference with author not selected from typeahead" do
    assert_raise(RuntimeError,
                 "Should raise exception because author typeahead has value \
                 but author id does not match.") do
      Reference::AsEdited.create({ "ref_type_id" => "17266",
                                   "title" => "ss",
                                   "published" => "1",
                                   "ref_author_role_id" => "17281",
                                   "edition" => "",
                                   "volume" => "",
                                   "pages" => "",
                                   "year" => "",
                                   "publication_date" => "",
                                   "notes" => "" },
                                 { "parent_typeahead" => "",
                                   "parent_id" => "",
                                   "author_typeahead" => "sadf",
                                   "author_id" => "" },
                                 "fred")
    end
  end
end
