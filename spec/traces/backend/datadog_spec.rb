# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'traces'

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
end

RSpec.describe Traces::Backend::Datadog do
	subject(:instance) {MyClass.new}
	
	it "has a version number" do
		expect(Traces::Backend::Datadog::VERSION).not_to be nil
	end
	
	it "can invoke trace wrapper" do
		expect(instance).to receive(:trace).and_call_original
		
		instance.my_method(10)
	end
	
	describe Datadog::Span do
		subject(:span) {instance.my_span}
		
		describe '#name' do
			subject(:name) {span.name}
			
			it {is_expected.to be == "my_span"}
		end
		
		describe '#trace_context' do
			subject(:context) {instance.trace_context(span)}
			
			describe '#trace_id' do
				subject(:trace_id) {context.trace_id}
				
				it {is_expected.to_not be_nil}
			end
		end
		
		describe '#trace_context=' do
			subject(:context) {instance.trace_context(span)}
			
			it "can update trace context" do
				instance.trace_context = context
				expect(::Datadog.tracer.provider.context).to have_attributes(
					trace_id: context.trace_id,
					span_id: context.parent_id
				)
			end
			
			it "can round-trip trace context" do
				parsed_context = Traces::Context.parse(context.to_s)
				
				instance.trace_context = parsed_context
				
				expect(::Datadog.tracer.provider.context).to have_attributes(
					trace_id: context.trace_id,
					span_id: context.parent_id
				)
			end
		end
	end
	
	describe Traces::Context do
		subject(:context) {instance.my_context}
		
		describe '#trace_id' do
			subject(:trace_id) {context.trace_id}
			
			it {is_expected.to_not be_nil}
		end
		
		describe '#parent_id' do
			subject(:parent_id) {context.parent_id}
			
			it {is_expected.to_not be_nil}
		end
	end
end
