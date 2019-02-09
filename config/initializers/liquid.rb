Liquid::Template.error_mode = :strict if Rails.env.development?

# module Liquid
#   class BlockBody
#     def render_node_to_output(node, output, context, skip_output = false)
#       node_output = node.render(context)
#       node_output = node_output.is_a?(Array) ? node_output.join : node_output.to_s
#       check_resources(context, node_output)
#       output << node_output unless skip_output
#     rescue MemoryError => e
#       raise e
#     rescue UndefinedVariable, UndefinedDropMethod, UndefinedFilter => e
#       context.handle_error(e, node.line_number)
#       output << nil
#     end
#   end
# end
