# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'traces'
require "traces/backend/datadog"

class MyClass
	def my_method(argument)
	end
end

Traces::Provider(MyClass) do
	def my_method(argument)
		trace('my_method', attributes: {argument: argument}) {super}
	end
	
	def my_span
		trace('my_span') {|span| return span}
	end
	
	def my_context
		trace('my_context') {|span| return self.trace_context}
	end

	def my_span_and_context
		trace('my_span_and_context') {|span| return span, self.trace_context}
	end
end

describe Traces::Backend::Datadog do
	let(:instance) {MyClass.new}
	
	it "has a version number" do
		expect(Traces::Backend::Datadog::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
	
	it "can invoke trace wrapper" do
		expect(instance).to receive(:trace)
		
		instance.my_method(10)
	end
	
	describe Datadog::Tracing::Span do
		let(:span) {instance.my_span}
		
		it "has a valid name" do
			expect(span).to have_attributes(
				name: be == "my_span"
			)
		end
		
		it "can assign attributes" do
			span["my_key"] = "tag_value"
			
			expect(span["my_key"]).to be == "tag_value"
		end
	end
	
	describe Datadog::Tracing::TraceOperation do
		let(:span_and_context) {instance.my_span_and_context}
		let(:span) {span_and_context.first}
		let(:context) {span_and_context.last}

		with '#trace_context' do
			it "has a valid trace id" do
				expect(context).to have_attributes(
					trace_id: be != nil
				)
			end
		end
		
		describe '#trace_context=' do
			it "can update trace context" do
				instance.trace_context = context
				
				span = instance.my_span
				
				expect(span).to have_attributes(
					trace_id: be == context.trace_id,
					parent_id: be == context.parent_id
				)
			end
			
			it "can round-trip trace context" do
				parsed_context = Traces::Context.parse(context.to_s)
				
				instance.trace_context = parsed_context
				
				span = instance.my_span
				
				expect(span).to have_attributes(
					trace_id: be == context.trace_id,
					parent_id: be == context.parent_id
				)
			end
		end
	end
	
	describe Traces::Context do
		let(:context) {instance.my_context}
		
		it "has a valid context" do
			expect(context).to have_attributes(
				trace_id: be != nil,
				parent_id: be != nil,
			)
		end
	end
end