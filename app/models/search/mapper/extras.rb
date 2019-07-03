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
#   Maps the help and examples for specific search targets to
#   file locations.
class Search::Mapper::Extras
  attr_reader :partial

  def initialize(params)
    debug("Start for #{params[:extra_id]}")
    @partial = MAP[params[:extras_id]]
  end

  def debug(s)
    Rails.logger.debug("Search::Extras::Mapper #{s}")
  end

  MAP = {
    "reference-search-help" => "references/advanced_search/help",
    "name-search-help" => "names/advanced_search/help",
    "name-plus-instances-search-help" => "names/advanced_search/help",
    "author-search-help" => "authors/advanced_search/help",
    "instance-search-help" => "instances/advanced_search/help",
    "tree-search-help" => "trees/advanced_search/help",
    "review-search-help" => "audits/advanced_search/help",
    "references-accepted-names-search-help" =>
    "references/advanced_search/with_novelties/help",
    "references-names-full-synonymy-search-help" =>
    "references/advanced_search/names_full_synonymy/help",
    "reference-search-examples" => "references/advanced_search/examples",
    "name-search-examples" => "names/advanced_search/examples",
    "name-plus-instances-search-examples" => "names/advanced_search/examples",
    "author-search-examples" => "authors/advanced_search/examples",
    "instance-search-examples" => "instances/advanced_search/examples",
    "tree-search-examples" => "trees/advanced_search/examples",
    "review-search-examples" => "audits/advanced_search/examples",
    "references-accepted-names-search-examples" =>
    "references/advanced_search/with_novelties/examples",
    "references-names-full-synonymy-search-examples" =>
    "references/advanced_search/names_full_synonymy/examples",
    "name-search-advanced" => "names/advanced_search/advanced",
    "reference-search-advanced" => "references/advanced_search/advanced",
    "references-with-novelties-search-advanced" =>
    "references/advanced_search/with_novelties/advanced",
    "references-names-full-synonymy-search-advanced" =>
    "references/advanced_search/names_full_synonymy/advanced",
    "author-search-advanced" => "authors/advanced_search/advanced",
    "instance-search-advanced" => "instances/advanced_search/advanced",
    "tree-search-advanced" => "trees/advanced_search/advanced",
    "review-search-advanced" => "audits/advanced_search/advanced",
    "references-shared-names-search-help" =>
    "references/advanced_search/shared_names/help",
    "references-shared-names-search-examples" =>
    "references/advanced_search/shared_names/examples",
    "references-shared-names-search-advanced" =>
    "references/advanced_search/shared_names/advanced",
  }.freeze
end
