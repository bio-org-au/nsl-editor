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

# A name review comment is highlighted as "fresh" for its first hour, the same
# as other search results. The partial used to test `unless fresh?`, which
# highlighted every comment except the new ones.
class NameReviewCommentRecordPartialTest < ActionView::TestCase
  def comment_created_at(time)
    Loader::Name::Review::Comment.new(
      id: 1,
      comment: "A review comment",
      batch_reviewer: loader_batch_batch_reviewers(:name_reviewer_for_batch_one),
      created_at: time
    )
  end

  def render_record_for(comment)
    render(
      partial: "application/search_results/main/loader/name/review/comment_record",
      locals: { search_result: comment, give_me_focus: false }
    )
  end

  # The partial is a bare <tr>, which the HTML parser drops outside a table.
  def row
    Nokogiri::HTML::DocumentFragment.parse("<table>#{rendered}</table>").at_css("tr")
  end

  test "highlights a comment made in the last hour" do
    render_record_for(comment_created_at(10.minutes.ago))

    assert_includes row["class"].split, "fresh"
  end

  test "does not highlight a comment older than an hour" do
    render_record_for(comment_created_at(2.hours.ago))

    assert_includes row["class"].split, "search-result"
    assert_not_includes row["class"].split, "fresh"
  end
end
