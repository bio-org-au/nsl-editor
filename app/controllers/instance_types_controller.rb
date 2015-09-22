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
class InstanceTypesController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_filter :hide_details

  # GET /instance_types
  def index 
    @instance_types = InstanceType.all.order("sort_order,name")
  end

  private

  def hide_details
    @no_search_result_details = true
  end

end
