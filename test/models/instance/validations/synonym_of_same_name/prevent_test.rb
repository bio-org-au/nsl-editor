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

# Single instance model test.
class InstanceValidationPreventSynonymOfSameNameTest < ActiveSupport::TestCase
  test "instance prevent synonym of same name" do
    instance_1 = instances(:britten_created_angophora_costata)
    instance_2 = instances(:angophora_costata_in_stanley)
    syn = Instance.new
    syn.instance_type = InstanceType.find_by(name: 'taxonomic synonym')
    syn.this_is_cited_by = instance_1
    syn.reference = instance_1.reference
    syn.this_cites = instance_2
    syn.name = instance_2.name
    syn.created_by = 'tester'
    syn.updated_by = 'tester'
 
    assert syn.name_id == syn.this_cites.name_id,
           "Name IDs must match for this test."
    assert_raises(ActiveRecord::RecordInvalid,
                  "Synonym of itself shouldn't be saved") do
      syn.save!
    end
  end
end
