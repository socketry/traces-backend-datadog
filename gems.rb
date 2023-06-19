# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

source 'https://rubygems.org'

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
	
	gem "utopia-project"
end

group :test do
	gem "bake-test"
	gem "bake-test-external"
	
	gem "sus"
	gem "covered"
	gem "console"
end
