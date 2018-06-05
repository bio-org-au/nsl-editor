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

# Single name model test.
class NameAsServicesDeleteSuccessTest < ActiveSupport::TestCase
  setup do
    stub_request(:delete,
                 "#{action}?apiKey=test-api-key&reason=#{reason}")
      .with(headers: headers)
      .to_return(status: 200, body: { ok: true }.to_json, headers: {})
  end

  def action
    "http://localhost:9090/nsl/services/rest/name/apni/540036697/api/delete"
  end

  def reason
    "200%20this%20is%20the%20reason....."
  end

  def headers
    { "Accept" => "application/json",
      "Accept-Encoding" => "gzip, deflate",
      "Host" => "localhost:9090",
      "User-Agent" => /ruby/ }
  end

  test "url" do
    name_id = names(:name_to_delete).id
    name = Name::AsServices.find(name_id)
    assert name.delete_with_reason("200 this is the reason....."),
           "Should be true"
  end
end
