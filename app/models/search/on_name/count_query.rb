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

# Core Name count query class
# TODO: sort out common and cultivars
#   if @parsed_request.common_and_cultivar ||
#      where_clauses.common_and_cultivar_included?
#      || @parsed_request.include_common_and_cultivar_session
#     Rails.logger.debug("Search::OnName::ListQuery#prepare_query yes,
#     we need common, cultivars")
#     @common_and_cultivar_included = true
#   else
#     Rails.logger.debug("Search::OnName::ListQuery#prepare_query no,
#     we will not look for common, cultivars")
#     unless @parsed_request.common_and_cultivar
#       prepared_query = prepared_query.not_common_or_cultivar
#     end
#     @common_and_cultivar_included = false
#   end
# Handle queries that just need a count of the records.
class Search::OnName::CountQuery
  attr_reader :sql, :info_for_display, :common_and_cultivar_included

  def initialize(parsed_request)
    @parsed_request = parsed_request
    prepare_query
    @info_for_display = "nothing yet from count query"
  end

  def prepare_query
    Rails.logger.debug("Search::OnName::CountQuery#prepare_query")
    # prepared_query = Name.includes(:ref_type)
    prepared_query = Name.all
    where_clauses = Search::OnName::WhereClauses.new(@parsed_request,
                                                     prepared_query)
    prepared_query = where_clauses.sql
    @sql = prepared_query
  end
end
