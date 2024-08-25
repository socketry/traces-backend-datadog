# frozen_string_literal: true

require_relative "lib/traces/backend/datadog/version"

Gem::Specification.new do |spec|
	spec.name = "traces-backend-datadog"
	spec.version = Traces::Backend::Datadog::VERSION
	
	spec.summary = "A traces backend for Datadog."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/traces-backend-datadog"
	
	spec.metadata = {
		"source_code_uri" => "https://github.com/socketry/traces-backend-datadog.git",
	}
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "datadog", "~> 2.3"
	spec.add_dependency "traces", "~> 0.10"
end
