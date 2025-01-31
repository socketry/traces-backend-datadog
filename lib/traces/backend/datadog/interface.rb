# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require 'datadog'

require 'traces/context'
require_relative 'version'

module Traces
	module Backend
		module Datadog
			module Interface
				def trace(name, resource: nil, attributes: {}, &block)
					::Datadog::Tracing.trace(name, resource: resource, tags: attributes, &block)
				end
				
				def trace_context=(context)
					if context
						trace_digest = ::Datadog::Tracing::TraceDigest.new(
							# We force these to be integers otherwise Datadog can fail internally:
							trace_id: context.trace_id.to_i,
							span_id: context.parent_id.to_i,
							trace_sampling_priority: context.sampled? ? 1 : 0,
						)
						
						::Datadog::Tracing.continue_trace!(trace_digest)
					end
				end
				
				def trace_context
					return nil unless trace = ::Datadog::Tracing.active_trace
					
					flags = 0
					
					if trace.sampled?
						flags |= Context::SAMPLED
					end
					
					return Context.new(
						trace.id,
						trace.active_span.id,
						flags,
						nil,
						remote: false,
					)
				end
				
				def active?
					!!::Datadog::Tracing.active_trace
				end
			end
		end
		
		Interface = Datadog::Interface
	end
end
