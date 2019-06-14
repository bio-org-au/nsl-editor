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

# Single controller test.
class NamesNewRowScientificHybridFormulaSimpleTest < ActionController::TestCase
  tests NamesController

  test "editor should be able to start a new scientific hybrid formula" do
    @request.headers["Accept"] = "application/javascript"
    @request.session["username"] = "fred"
    @request.session["user_full_name"] = "Fred Jones"
    @request.session["groups"] = ["edit"]
    xhr(:get, :new_row,
        { type: "hybrid-formula" },
        {},
        xhr: true)
    assert_response :success,
                    "Cannot start new row for a scientific hybrid formula name"
    assert_match(/search-results-table/,
                 response.body.to_s,
                 "Missing expected element 1")
    assert_match(/names.new.category=hybrid.formula/,
                 response.body.to_s,
                 "Missing expected element 2")
  end
end
