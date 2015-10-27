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
class Search::OnName::WhereClauses

  attr_reader  :sql

  def initialize(parsed_request, incoming_sql)
    @parsed_request = parsed_request
    @sql = incoming_sql
    build_sql
  end

  def build_sql
    Rails.logger.debug("Search::OnName::WhereClause.sql")
    remaining_string = @parsed_request.where_arguments.downcase 
    @common_and_cultivar_included = @parsed_request.common_and_cultivar
    @sql = @sql.for_id(@parsed_request.id) if @parsed_request.id
    x = 0 
    until remaining_string.blank?
      field,value,remaining_string = Search::OnName::NextCriterion.new(remaining_string).get 
      Rails.logger.info("field: #{field}; value: #{value}")
      add_clause(field,value)
      x += 1
      raise "endless loop #{x}" if x > 50
    end
  end

  def add_clause(field,value)
    if field.blank? && value.blank?
      @sql
    elsif field.blank? || field.match(/\Aname:\z/)
      @sql = @sql.lower_full_name_like(value.downcase)
    else 
      # we have a field
      canonical_field = canon_field(field)
      canonical_value = value.blank? ? '' : canon_value(value)
      @common_and_cultivar_included = @common_and_cultivar_included || AUTO_INCLUDE_COMMON_AND_CULTIVAR_FIELDS.has_key?(canonical_field)
      if ALLOWS_MULTIPLE_VALUES.has_key?(canonical_field) && canonical_value.split(/,/).size > 1
        case canonical_field
        when /\Arank:\z/
          @sql = @sql.where("name_rank_id in (select id from name_rank where lower(name) in (?))",canonical_value.split(',').collect {|v| v.strip})
        when /\Atype:\z/
          @sql = @sql.where("name_type_id in (select id from name_type where lower(name) in (?))",canonical_value.split(',').collect {|v| v.strip})
        when /\Aname-status:\z/
          @sql = @sql.where("name_status_id in (select id from name_status where lower(name) in (?))",canonical_value.split(',').collect {|v| v.strip})
        else
          raise "The field '#{field}' currently cannot handle multiple values separated by commas." 
        end
      elsif canonical_field.match(/\Acomments-by:\z/)
        @sql = @sql.where("exists (select null from comment where comment.name_id = name.id and (lower(comment.created_by) like ? or lower(comment.updated_by) like ?))",
                          canonical_value,canonical_value)
      elsif WHERE_INTEGER_VALUE_HASH_THRICE.has_key?(canonical_field)
        @sql = @sql.where(WHERE_INTEGER_VALUE_HASH_THRICE[canonical_field],canonical_value.to_i,canonical_value.to_i,canonical_value.to_i)
      elsif WHERE_INTEGER_VALUE_HASH_TWICE.has_key?(canonical_field)
        @sql = @sql.where(WHERE_INTEGER_VALUE_HASH_TWICE[canonical_field],canonical_value.to_i,canonical_value.to_i)
      elsif WHERE_INTEGER_VALUE_HASH.has_key?(canonical_field)
        @sql = @sql.where(WHERE_INTEGER_VALUE_HASH[canonical_field],canonical_value.to_i)
      elsif WHERE_ASSERTION_HASH.has_key?(canonical_field)
        @sql = @sql.where(WHERE_ASSERTION_HASH[canonical_field])
      else
        raise 'No way to handle field.' unless WHERE_VALUE_HASH.has_key?(canonical_field)
        @sql = @sql.where(WHERE_VALUE_HASH[canonical_field],canonical_value)
      end
    end
  end

  def canon_value(value)
    value.gsub(/\*/,'%')
  end

  def canon_field(field)
    if WHERE_INTEGER_VALUE_HASH.has_key?(field)
      field
    elsif WHERE_INTEGER_VALUE_HASH_TWICE.has_key?(field)
      field
    elsif WHERE_INTEGER_VALUE_HASH_THRICE.has_key?(field)
      field
    elsif WHERE_ASSERTION_HASH.has_key?(field)
      field
    elsif WHERE_VALUE_HASH.has_key?(field)
      field
    elsif CANONICAL_FIELD_NAMES.has_value?(field)
      field
    elsif CANONICAL_FIELD_NAMES.has_key?(field)
      CANONICAL_FIELD_NAMES[field]
    else
      raise "Cannot search names for: #{field}." unless CANONICAL_FIELD_NAMES.has_key?(field)
    end
  end

  def xadd_clause(field,value)
    case
      when field.blank? && value.blank?
        @sql
      when field.blank?
        @sql = @sql.lower_full_name_like(value.downcase)
      when value.split(/,/).size > 1
        case field
        when /\Arank:\z/
          @sql = @sql.where("name_rank_id in (select id from name_rank where lower(name) in (?))",value.split(',').collect {|v| v.strip})
        end
      when field.match(/\Acomments-by:\z/)
        @sql = @sql.where("exists (select null from comment where comment.name_id = name.id and (lower(comment.created_by) like ? or lower(comment.updated_by) like ?))",
                          value,value) when WHERE_INTEGER_VALUE_HASH.has_key?(field)
        @sql = @sql.where(WHERE_INTEGER_VALUE_HASH[field],value.to_i)
      when WHERE_VALUE_HASH.has_key?(field)
        @sql = @sql.where(WHERE_VALUE_HASH[field],value)
      else
        raise 'No such field.' unless WHERE_VALUE_HASH.has_key?(field)
    end
  end

  def common_and_cultivar_included?
    @common_and_cultivar_included
  end

  WHERE_INTEGER_VALUE_HASH = { 
    'id:' => "id = ? ",
    'author-id:' => "author_id = ? ",
    'base-author-id:' => "base_author_id = ? ",
    'ex-base-author-id:' => "ex_base_author_id = ? ",
    'ex-author-id:' => "ex_author_id = ? ",
    'sanctioning-author-id:' => "sanctioning_author_id = ? "
  }

  WHERE_INTEGER_VALUE_HASH_TWICE = { 
    'parent-or-second-parent-id:' => "parent_id = ? or second_parent_id = ? ",
    'parent-id:' => "id = ? or parent_id = ?",
    'second-parent-id:' => "id = ? or second_parent_id = ? "
  }

  WHERE_INTEGER_VALUE_HASH_THRICE = { 
    'parent-or-second-parent-id:' => "id = ? or parent_id = ? or second_parent_id = ? "
  }

  WHERE_ASSERTION_HASH = { 
    'is-a-duplicate:' => " duplicate_of_id is not null",
    'is-not-a-duplicate:' => " duplicate_of_id is null",
    'is-a-parent:' => " exists (select null from name child where child.parent_id = name.id) ",
    'is-not-a-parent:' => " not exists (select null from name child where child.parent_id = name.id) ",
    'has-no-parent:' => " parent_id is null",
    'is-a-child:' => " parent_id is not null",
    'is-not-a-child:' => " parent_id is null",
    'has-a-second-parent:' => " second_parent_id is not null",
    'has-no-second-parent:' => " second_parent_id is null",
    'is-a-second-parent:' => " exists (select null from name child where child.second_parent_id = name.id) ",
    'is-not-a-second-parent:' => " not exists (select null from name child where child.second_parent_id = name.id) "
  }

  WHERE_VALUE_HASH = { 
    'rank:' => "name_rank_id in (select id from name_rank where lower(name) like ?)",
    'type:' => "name_type_id in (select id from name_type where lower(name) like ?)",
    'status:' => "name_status_id in (select id from name_status where lower(name) like ?)",
    'below-rank:' => "name_rank_id in (select id from name_rank where sort_order > (select sort_order from name_rank the_nr where lower(the_nr.name) like ?))",
    'above-rank:' => "name_rank_id in (select id from name_rank where sort_order < (select sort_order from name_rank the_nr where lower(the_nr.name) like ?))",
    'author:' => "author_id in (select id from author where lower(abbrev) like ?)",
    'ex-author:' => "ex_author_id in (select id from author where lower(abbrev) like ?)",
    'base-author:' => "base_author_id in (select id from author where lower(abbrev) like ?)",
    'ex-base-author:' => "ex_base_author_id in (select id from author where lower(abbrev) like ?)",
    'sanctioning-author:' => "sanctioning_author_id in (select id from author where lower(abbrev) like ?)",
    'comments:' => " exists (select null from comment where comment.name_id = name.id and comment.text like ?) ",
    'comments-by:' => " exists (select null from comment where comment.name_id = name.id and comment.text like ?) ",
    'comments-but-no-instances:' => 
      "exists (select null from comment where comment.name_id = name.id and comment.text like ?) and not exists (select null from instance where name_id = name.id)"
  }

  CANONICAL_FIELD_NAMES = {
    'nr:' => 'rank:',
    'r:' => 'rank:',
    'name-rank:' => 'rank:',
    't:' => 'type:',
    'nt:' => 'type:',
    'name-type:' => 'type:'
  }

  AUTO_INCLUDE_COMMON_AND_CULTIVAR_FIELDS = {
    'type:' => true,
    'id:' => true,
    'parent-id:' => true 
  }

  ALLOWS_MULTIPLE_VALUES = {
    'rank:' => true,
    'name-status:' => true,
    'type:' => true
  }


end


