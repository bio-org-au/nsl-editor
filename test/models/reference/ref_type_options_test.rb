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

# The ref type options on the reference edit form. A reference with children
# is steered towards the parent type of its earliest-created child.
class ReferenceRefTypeOptionsTest < ActiveSupport::TestCase
  test "a reference with no children gets the plain options" do
    reference = references(:paper_by_britten_on_angophora)
    assert_empty reference.children

    assert_equal RefType.options, reference.ref_type_options
  end

  test "a journal whose children are all papers prefers Journal" do
    journal = references(:journal_with_papers)
    assert_equal [ "Paper" ], journal.children.map { |c| c.ref_type.name }.uniq

    assert_equal RefType.options_with_preference("Journal"), journal.ref_type_options
  end

  test "children of different types: the earliest-created child decides" do
    book = references(:parented_book_edited_by_brassard)
    section = book.children.sole
    paper = references(:paper_by_britten_on_angophora)
    assert_operator section.id, :<, paper.id, "test assumes the section has the lower id"
    paper.update_column(:parent_id, book.id)

    # Section's parent type is Book; a Paper's would be Journal.
    assert_equal RefType.options_with_preference("Book"), book.reload.ref_type_options
  end

  test "earliest-created child with no parent type gives the plain options" do
    # book_by_brassard's children are of many types; the lowest id is an Index.
    book = references(:book_by_brassard)
    assert_equal "Index", book.children.order(:id).first.ref_type.name

    assert_equal RefType.options, book.ref_type_options
  end
end
