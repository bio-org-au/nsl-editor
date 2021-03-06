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

# Test authors editing comments.
class AuthorsEditCommentsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  test "create author comment" do
    visit_home_page
    standard_page_assertions
    select "Authors", from: "query-on"
    fill_in "search-field", with: "*"
    select "just: 1", from: "query-limit"
    click_on "Search"
    all(".takes-focus").first.click
    click_on "Comments"
    fill_in "comment_text", with: "this is a test comment"
    assert_difference("Comment.count") do
      within("#search-result-details") do
        find("#comment-create-btn").click
      end
      sleep(0.5)
      assert page.has_content?("- gclarke"), "No new comment by gclarke."
      assert page.has_button?("Save"), "No new comment."
    end
  end
end
