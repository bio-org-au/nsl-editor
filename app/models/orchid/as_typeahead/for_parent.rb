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

# Provide typeahead suggestions based on a search term.
#
# Offer parents
# Only accepted orchids
class Orchid::AsTypeahead::ForParent
  attr_reader :suggestions,
              :params
  SEARCH_LIMIT = 50

  def initialize(params)
    @params = params
    @suggestions = if @params[:term].blank?
                     []
                   else
                     query
                   end
  end

  def prepared_search_term
    @params[:term].tr("*", "%").downcase + "%"
  end

  def core_query
    Orchid.where(record_type: 'accepted')
        .where(["lower(taxon) like ?",prepared_search_term])
        .avoids_id(@params[:avoid_id].try("to_i") || -1)
        .order("taxon")
        .limit(SEARCH_LIMIT)
  end

  def query
    @qry = core_query
    @qry = @qry.select('id, taxon')
               .collect do |n|
      {value: "#{n.taxon} (#{n.id}) ",
       id: n.id}
    end
  end
end
