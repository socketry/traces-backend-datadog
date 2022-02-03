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

require 'ddtrace'

require 'traces/context'
require_relative 'version'

module Traces
	module Backend
		module Datadog
			module SpanInterface
				def []= key, value
					set_tag(key, value)
				end
			end
			
			::Datadog::Span.prepend(SpanInterface)
			
			module Interface
				def trace(name, attributes: {}, resource: nil, &block)
					::Datadog.tracer.trace(name, tags: attributes, resource: resource, &block)
				end
				
				def trace_context=(context)
					if context
						::Datadog.tracer.provider.context = ::Datadog::Context.new(
							# We force these to be integers otherwise Datadog can fail internally:
							trace_id: context.trace_id.to_i,
							span_id: context.parent_id.to_i,
							sampled: context.sampled?,
						)
					end
				end
				
				def trace_context(span = ::Datadog.tracer.active_span)
					return nil unless span
					
					flags = 0
					
					if span.sampled
						flags |= Context::SAMPLED
					end
					
					return Context.new(
						span.trace_id,
						span.span_id,
						flags,
						nil,
						remote: false,
					)
				end
			end
		end
		
		Interface = Datadog::Interface
	end
end