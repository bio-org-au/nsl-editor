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
# == Schema Information
#
# Table name: ref_type
#
#  id                 :bigint           not null, primary key
#  description_html   :text
#  lock_version       :bigint           default(0), not null
#  name               :string(50)       not null
#  parent_optional    :boolean          default(FALSE), not null
#  use_parent_details :boolean          default(FALSE), not null
#  parent_id          :bigint
#  rdf_id             :string(50)
#
# Indexes
#
#  ref_type_rdfid                (rdf_id)
#  uk_4fp66uflo7rgx59167ajs0ujv  (name) UNIQUE
#
# Foreign Keys
#
#  fk_51alfoe7eobwh60yfx45y22ay  (parent_id => ref_type.id)
#
class RefType < ApplicationRecord
  self.table_name = "ref_type"
  self.primary_key = "id"

  belongs_to :parent, class_name: "RefType", foreign_key: "parent_id", optional: true
  has_many :children,
    class_name: "RefType",
    foreign_key: "parent_id",
    dependent: :restrict_with_exception

  has_many :references

  def name?
    name == "Name"
  end

  def unknown?
    name == "Unknown"
  end

  def indefinite_article
    case name.first.downcase
    when "i" then "an"
    when "h" then "an"
    when "u" then "an"
    else "a"
    end
  end

  def self.unknown
    RefType.where(name: "Unknown").first
  end

  def self.options
    all.order(:name).collect { |r| [ r.name, r.id ] }
  end

  # Options for a reference whose children have the given ref types, with the
  # expected parent type preferred and the others marked "may be incompatible".
  #
  # Limits: only the first ref type in the list is considered, so callers must
  # pass the list in a definite order (Reference#ref_type_options orders the
  # children by id). If children have ref types with different parent types,
  # e.g. a Section (parent Book) and a Paper (parent Journal), the others are
  # ignored and no conflict is reported. With no children, or a first child
  # whose type has no parent type, the plain options are returned.
  def self.options_for_parent_of(children_ref_types)
    first = children_ref_types.first
    return options if first.nil? || first.parent_id.blank?

    options_with_preference(first.parent.name)
  end

  def self.options_with_preference(pref)
    all.order(:name)
      .collect do |r|
      if /#{pref}/.match?(r.name)
        [ r.name, r.id, { class: "none" } ]
      else
        [ "#{r.name} - may be incompatible with child", r.id, { class: "red" } ]
      end
    end
  end

  def self.query_form_options
    all.sort_by(&:name)
      .collect { |n| [ n.name, n.name.downcase, { class: "" } ] }
  end

  def rule
    rule = if parent_id.blank?
      "cannot be within another reference"
    elsif parent_optional == true
      optional_parent_rule(parent)
    else
      required_parent_rule(parent)
    end
    "#{indefinite_article.capitalize} #{name.downcase} #{rule}."
  end

  def optional_parent_rule(parent)
    "may be within #{parent.indefinite_article} #{parent.name.downcase}"
  end

  def required_parent_rule(parent)
    "should be within #{parent.indefinite_article} #{parent.name.downcase}"
  end

  def parent_allowed?
    parent_id.present?
  end

  def part?
    name == "Part"
  end

  def reference_year_required?
    [
      "chapter",
      "database record",
      "herbarium annotation",
      "personal communication",
      "paper",
      "section"
    ].include?(name.downcase)
  end
end
