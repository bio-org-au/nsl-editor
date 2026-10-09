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

# The loader name Details tab shows several batch-loaded text fields as HTML.
# Each must strip scripts and event handlers but keep ordinary formatting.
class LoaderNameDetailsTabSanitizingTest < ActionView::TestCase
  UNSAFE = %(<script>alert("x")</script><img src="x" onerror="alert('y')"><i>Eucalyptus</i> sens. lat.; Smith &amp; Jones)

  # The Details tab partials render "detail_line", which lives in app/views/application.
  setup do
    view.lookup_context.prefixes |= [ "application" ]
    # Skip the edit-only controls; they need a signed-in user.
    view.define_singleton_method(:can?) { |*| false }
  end

  # Parse the output so escaped source text (e.g. "&lt;script") doesn't count.
  def assert_no_active_content
    html = Nokogiri::HTML::DocumentFragment.parse(rendered)
    assert_empty html.css("script"), "rendered a <script> element"
    assert_empty html.css("[onerror]"), "rendered an onerror attribute"
  end

  def show(fixture, field, text = UNSAFE)
    @loader_name = loader_names(fixture)
    @loader_name.public_send("#{field}=", text)
  end

  test "Misapp HTML line sanitizes original_text" do
    show(:misapp_no_parent, :original_text)
    render(partial: "loader/names/tabs/details/core_data")

    assert_no_active_content
    assert_includes rendered, "<i>Eucalyptus</i>"
  end

  test "Misapp HTML line still breaks at semicolons without splitting &amp;" do
    show(:misapp_no_parent, :original_text, "<i>Eucalyptus</i> sens. lat.; Smith &amp; Jones")
    render(partial: "loader/names/tabs/details/core_data")

    assert_includes rendered, "sens. lat.;<br>"
    assert_includes rendered, "Smith &amp; Jones"
  end

  test "Original Text (HTML) sanitizes original_text" do
    show(:misapp_no_parent, :original_text)
    render(partial: "loader/names/tabs/details/core_data_2")

    assert_no_active_content
    assert_includes rendered, "<i>Eucalyptus</i>"
  end

  test "remark to reviewers line sanitizes remark_to_reviewers" do
    show(:accepted_one, :remark_to_reviewers)
    render(partial: "loader/names/tabs/details/core_data")

    assert_no_active_content
    assert_includes rendered, "<i>Eucalyptus</i>"
  end

  test "higher rank comment line sanitizes higher_rank_comment" do
    show(:accepted_one, :higher_rank_comment)
    render(partial: "loader/names/tabs/details/core_data")

    assert_no_active_content
    assert_includes rendered, "<i>Eucalyptus</i>"
  end
end
