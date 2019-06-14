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
class DistRegion < ActiveRecord::Base
  self.table_name = "dist_region"
  self.primary_key = "id"
  self.sequence_name = "nsl_global_seq"

  has_many :dist_entries,
           foreign_key: "region_id"

  def self.sorted
    DistRegion.all
        .sort {|a, b| a.sort_order <=> b.sort_order}
  end

  def self.region_names
    DistRegion.all
        .sort {|a, b| a.sort_order <=> b.sort_order}
        .collect {|dr| dr.name}
  end

end
