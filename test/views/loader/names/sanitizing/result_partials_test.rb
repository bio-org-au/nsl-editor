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

# Loader name text fields come from batch loads, and some can also be edited
# by batch loaders, so they are untrusted. Every search-result and print
# partial that shows them must strip scripts and event handlers but keep
# ordinary formatting such as italics.
class LoaderNameResultPartialsSanitizingTest < ActionView::TestCase
  UNSAFE = %(<script>alert("x")</script><img src="x" onerror="alert('y')"><i>Eucalyptus</i> remark)

  PRINT = "application/search_results/print/records/loader/name/record_types"
  FIXTURES = { "accepted" => :accepted_one, "excluded" => :accepted_one,
               "synonym" => :synonym_no_parent, "misapplied" => :misapp_no_parent, }.freeze

  setup do
    # notes are only shown to users who can see batches
    view.define_singleton_method(:can?) { |*| true }
  end

  # Parse the output so escaped source text (e.g. "&lt;script") doesn't count.
  def assert_no_active_content
    html = Nokogiri::HTML::DocumentFragment.parse("<table>#{rendered}</table>")
    assert_empty html.css("script"), "rendered a <script> element"
    assert_empty html.css("[onerror]"), "rendered an onerror attribute"
  end

  def loader_name_with(fixture, field)
    loader_name = loader_names(fixture)
    loader_name.higher_rank_comment = nil
    loader_name.remark_to_reviewers = nil
    loader_name.notes = nil
    loader_name.synonym_type ||= "taxonomic synonym"
    loader_name.public_send("#{field}=", UNSAFE)
    loader_name
  end

  FIXTURES.each do |record_type, fixture|
    %w[higher_rank_comment remark_to_reviewers notes].each do |field|
      test "print #{record_type} sanitizes #{field}" do
        render(partial: "#{PRINT}/#{record_type}", locals: { search_result: loader_name_with(fixture, field) })

        assert_no_active_content
        assert_includes rendered, "<i>Eucalyptus</i> remark"
      end
    end
  end

  test "search result remarks and comments sanitizes higher_rank_comment" do
    render(partial: "application/search_results/link_texts/loader/name/decorate/remarks_and_comments",
           locals: { search_result: loader_name_with(:accepted_one, "higher_rank_comment") })

    assert_no_active_content
    assert_includes rendered, "<i>Eucalyptus</i> remark"
  end
end
