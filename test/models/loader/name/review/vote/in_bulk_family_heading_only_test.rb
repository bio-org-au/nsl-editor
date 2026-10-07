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

# Loader::Name::Review::Vote.in_bulk casts one vote for every accepted or
# excluded record in the same family and batch. The rule: bulk voting is only
# for family records, i.e. a heading of rank family. The voting screen only
# offers it there (votes/.../can_vote/_heading.html.erb).
#
# Bug (findings #8c): the guard was
#     throw(...) unless loader_name.record_type = loader_name.family?
# (assignment, not comparison). family? is the attribute query for the family
# column, which every loader name has, so the guard always passed: a bulk vote
# posted for any record (e.g. an accepted species) voted on its whole family.
# It also set record_type to true in memory as a side effect.
#
# Setup turns existing batch_one records into headings with update_columns so
# no callbacks run. The Myrtaceae records in batch_one include accepted ones.
class LoaderNameReviewVoteInBulkFamilyHeadingOnlyTest < ActiveSupport::TestCase
  setup do
    @review = loader_batch_batch_reviews(:review_one_on_batch_one)
    @org = orgs(:state_herb_1)

    @family_heading = loader_names(:misapp_no_parent)
    @family_heading.update_columns(record_type: "heading", rank: "family",
                                   simple_name: "Myrtaceae", full_name: "Myrtaceae",
                                   family: "Myrtaceae", parent_id: nil)

    @genus_heading = loader_names(:synonym_no_parent)
    @genus_heading.update_columns(record_type: "heading", rank: "genus", parent_id: nil)

    @accepted_record = loader_names(:zzz_test_parent_no_match) # accepted species, Myrtaceae
  end

  def bulk_vote_from(loader_name)
    params = ActionController::Parameters.new(
      loader_name_id: loader_name.id,
      batch_review_id: @review.id,
      org_id: @org.id,
      vote: true,
    ).permit!
    Loader::Name::Review::Vote.in_bulk(params, "tester")
  end

  def votes_count
    Loader::Name::Review::Vote.where(batch_review_id: @review.id, org_id: @org.id).count
  end

  # The cases the bug got wrong.
  test "bulk vote is refused for a record that is not a heading" do
    assert_raises(StandardError) { bulk_vote_from(@accepted_record) }
    assert_equal 0, votes_count, "No votes should be cast"
  end

  test "bulk vote is refused for a heading that is not of rank family" do
    assert_raises(StandardError) { bulk_vote_from(@genus_heading) }
    assert_equal 0, votes_count, "No votes should be cast"
  end

  # Control: the legitimate path must keep working after the fix.
  test "bulk vote from a family heading votes on the family's accepted and excluded records" do
    expected = Loader::Name.where(loader_batch_id: @review.loader_batch_id, family: "Myrtaceae")
      .where(record_type: %w[accepted excluded]).count
    assert_operator expected, :>, 0, "Setup: the family has accepted/excluded records"

    created = bulk_vote_from(@family_heading)

    assert_equal expected, created
    assert_equal expected, votes_count
  end
end
