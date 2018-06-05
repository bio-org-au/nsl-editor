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
class InstanceDeleteServiceNotFound404Test < ActiveSupport::TestCase
  setup do
    raw = { "action": "delete",
            "instance": {},
            "ok": false,
            "errors": ["Not found."] }
    stub_request(:delete,
                 "#{action}?apiKey=test-api-key&reason=Edit")
      .with(headers: headers)
      .to_return(status: 404, body: raw.to_json, headers: {})
  end

  def action
    "http://localhost:9090/nsl/services/rest/instance/apni/404/api/delete"
  end

  def headers
    { "Accept" => "application/json",
      "Accept-Encoding" => "gzip, deflate",
      "Host" => "localhost:9090",
      "User-Agent" => /ruby/ }
  end

  test "instance delete service not found 404" do
    exception = assert_raise(
      RuntimeError,
      "Should raise runtime exception for not found"
    ) do
      # The test mock service determines response based on the id
      Instance::AsServices.delete(404)
    end
    assert_match "Not found.", exception.message, "Wrong message"
  end
end
