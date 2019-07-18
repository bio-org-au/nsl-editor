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

# Instances are associated with a Name as:
# - standalone instances for the Name, or as
# - relationship instances that cite or are cited by those standalones.
#
# This class collects the instances associated with a single name
# in the accepted order and sets the display attributes for each record.
#
# The collection is in the results attribute.
#
# e.g.
# name = [find some name]
# instances = Instance::AsArray::ForName.new(name)
# puts instances.results.size
#
class Instance::AsArray::ForName < Array
  attr_reader :results
  NO_YEAR = ''

  def initialize(name)
    @results = []
    @already_shown = []
    sorted_instances(name.instances.includes([{reference: :author}, :instance_type])).each do |instance|
      if instance.standalone?
        show_standalone_instance(instance)
      else
        show_relationship_instance(name, instance)
      end
    end
  end

  def debug(s)
    Rails.logger.debug("Instance::AsArray::ForName: #{s}")
  end

  def sorted_instances(instances)
    instances.sort do |i1, i2|
      sort_fields(i1) <=> sort_fields(i2)
    end
  end

  def sort_fields(instance)
    [instance.reference.year || instance.reference.try('parent').try('year') || NO_YEAR,
     instance.instance_type.primaries_first,
     instance.reference.iso_publication_date || instance.reference.try('parent').try('iso_publication_date') || NO_YEAR,
     instance.reference.author.try("name") || "x"]
  end

  def show_standalone_instance(instance)
    debug("show_standalone_instance #{instance.id}")
    standalone_instance_records(instance).each do |one_instance|
      one_instance.show_primary_instance_type = true
      one_instance.consider_apc = true
      @results.push(one_instance)
    end
  end

  # Work on a single standalone instance starts here.
  # - display the instance as part of a concept
  # - find all child instances using the cited_by_id column
  #   (all instances that say they are cited by the standalone instance)
  #   - display these relationship instances as cited_by the standalone instance
  def standalone_instance_records(instance)
    debug("show_standalone_instance_records #{instance.id}")
    results = [instance.display_as_part_of_concept]
    records_cited_by_standalone(instance)
      .each do |cited_by_original_instance|
        cited_by_original_instance.expanded_instance_type =
          cited_by_original_instance.instance_type.name
        cited_by_original_instance.display_as = "instance-is-cited-by"
        results.push(cited_by_original_instance)
      end
    results
  end

  def records_cited_by_standalone(instance)
    debug("records_cited_by_standalone for instance #{instance.id}")
    Instance.joins(:instance_type, :name, :reference)
            .includes(:instance_type)
            .where(cited_by_id: instance.id)
            .in_nested_instance_type_order
            .order("reference.iso_publication_date,lower(name.full_name)")
  end

  def show_relationship_instance(name, instance)
    citing_instance = instance.this_is_cited_by
    return if @already_shown.include?(citing_instance.id)
    relationship_instance_records(name, citing_instance).each do |element|
      element.consider_apc = false
      @results.push(element)
    end
    @already_shown.push(citing_instance.id)
  end

  # NSL-536: If instance name is not the subject name then
  # do not show the instance type.
  def relationship_instance_records(name, instance)
    results = [instance.display_as_citing_instance_within_name_search]
    records_cited_by_relationship(instance)
      .each do |cited_by_original_instance|
      next unless cited_by_original_instance.name.id == name.id
      cited_by_original_instance.expanded_instance_type =
        cited_by_original_instance.instance_type.name
      results.push(with_display_as(cited_by_original_instance))
    end
    results
  end

  def with_display_as(instance)
    debug("with_display_as for instance #{instance.id}")
    if instance.misapplied?
      instance.display_as = "cited-by-relationship-instance"
    else
      instance.display_as = "cited-by-relationship-instance-name-only"
    end
    instance
  end

  def records_cited_by_relationship(instance)
    debug("records_cited_by_relationship for instance #{instance.id}")
    Instance.joins(:instance_type)
            .where(cited_by_id: instance.id)
            .in_nested_instance_type_order
  end
end
