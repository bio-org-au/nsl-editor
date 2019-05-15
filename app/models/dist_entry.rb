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

#  Distribution Region
class DistEntry < ActiveRecord::Base
  self.table_name = "dist_entry"
  self.primary_key = "id"
  self.sequence_name = "nsl_global_seq"

  belongs_to :dist_region,
             foreign_key: "region_id"

  has_and_belongs_to_many :dist_statuses,
                          join_table: "dist_entry_dist_status",
                          foreign_key: "dist_entry_status_id"

  def status
    dist_statuses
        .sort {|a, b| a.sort_order <=> b.sort_order}
        .collect {|it| it.name}.join(" and ")
  end

  def region
    dist_region.name
  end

  def entry
    "#{region} (#{status})".gsub(" (native)", '')
  end
end
