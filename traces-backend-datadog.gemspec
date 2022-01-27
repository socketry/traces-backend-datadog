
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
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_dependency "traces", "~> 0.5.0"
	spec.add_dependency "ddtrace", "~> 0.53"
	
	spec.add_development_dependency "rspec", "~> 3.0"
end
