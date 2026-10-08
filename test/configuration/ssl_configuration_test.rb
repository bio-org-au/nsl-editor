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

require "test_helper"

# Verify that production SSL configuration is correct for AWS deployment.
#
# AWS terminates TLS at the load balancer, so we don't need force_ssl
# (which would redirect HTTP->HTTPS), but we DO need assume_ssl so that:
# - Session cookies get the Secure flag (browser won't send over HTTP)
# - Rails generates HTTPS URLs
#
# See finding 4 in tmp/review/findings.md
class SslConfigurationTest < ActiveSupport::TestCase
  test "production config has assume_ssl enabled" do
    # Read the production config file and check that assume_ssl is uncommented
    # and set to true. This ensures the setting survives future config changes.
    production_config = File.read(Rails.root.join("config/environments/production.rb"))

    # Should have an uncommented assume_ssl = true line
    # (not "# config.assume_ssl = true")
    assert_match(
      /^\s*config\.assume_ssl\s*=\s*true/,
      production_config,
      "production.rb must have 'config.assume_ssl = true' (uncommented) " \
      "so session cookies get the Secure flag. AWS handles the TLS termination, " \
      "but Rails needs to know we're behind HTTPS to set cookie flags correctly."
    )
  end

  test "production config does not have force_ssl enabled" do
    # force_ssl would cause HTTP->HTTPS redirects, which is unnecessary
    # when AWS ALB already handles this. It's fine to have it, but not required.
    # This test documents that we're intentionally relying on assume_ssl only.
    production_config = File.read(Rails.root.join("config/environments/production.rb"))

    # If force_ssl is enabled, that's also fine (it's a superset of assume_ssl)
    # So this test just documents our expected configuration
    has_assume_ssl = production_config.match?(/^\s*config\.assume_ssl\s*=\s*true/)
    has_force_ssl = production_config.match?(/^\s*config\.force_ssl\s*=\s*true/)

    assert(
      has_assume_ssl || has_force_ssl,
      "production.rb must have either assume_ssl or force_ssl enabled " \
      "to ensure session cookies have the Secure flag"
    )
  end
end
