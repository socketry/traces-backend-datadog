# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'ddtrace'

require 'traces/context'
require_relative 'version'

# We introduce some compatibility interfaces for getting and setting tags:
module Datadog::Tracing::Metadata::Tagging
	alias []= set_tag
	alias [] get_tag
end

module Traces
	module Backend
		module Datadog
			module Interface
				def trace(name, attributes: {}, resource: nil, &block)
					::Datadog::Tracing.trace(name, tags: attributes, resource: resource, &block)
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
						trace.active_span.span_id,
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
