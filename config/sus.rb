# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

ENV['TRACES_BACKEND'] ||= 'traces/backend/datadog'

require 'ddtrace'

Datadog.configure do |config|
	# To enable debug mode
	# config.diagnostics.debug = true
	
	config.tracing.test_mode.enabled = true
end

require 'covered/sus'
include Covered::Sus
