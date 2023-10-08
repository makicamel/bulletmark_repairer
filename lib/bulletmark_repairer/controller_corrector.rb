# frozen_string_literal: true

class ControllerCorrector < Parser::TreeRewriter
  def on_class(node)
    node
      .children
      .each do |child_node|
        type, identifier = child_node.to_sexp_array.take(2)
        case type
        when :def
          target_nodes[identifier] = child_node
        when :begin
          child_node.children.each do |grand_child_node|
            type, identifier, callback_type, (_, callback_identifier) = grand_child_node.to_sexp_array
            if type == :def
              target_nodes[identifier] = grand_child_node
            elsif callback_type.in? %i[before_action after_action around_action]
              callbacks.append callback_identifier
            end
          end
        end
      end
    action_node = target_nodes.delete(action)
    insert_includes(node: action_node)
    return if patched?

    callbacks.each { |callback_identifier| insert_includes(node: target_nodes[callback_identifier]) }
  end

  private

  def patched?
    @patched ||= false
  end

  def target_nodes
    @target_nodes ||= {}
  end

  def callbacks
    @callbacks ||= []
  end

  def insert_includes(node:)
    return if patched?
    return unless node.respond_to?(:to_sexp_array)

    type, identifier = node.to_sexp_array.take(2)

    if type == :ivasgn && identifier == instance_variable_name
      insert_after node.children.last.location.expression, ".includes(#{associations})"
      @patched = true
    else
      node
        .children
        .reverse
        .each do |child_node|
          child_type, _, child_identifier = child_node.try(:to_sexp_array)
          if child_type == :send && target_nodes.key?(child_identifier)
            target_node = target_nodes.delete(child_node.to_sexp_array.last)
            insert_includes(node: target_node)
          else
            insert_includes(node: child_node)
          end
        end
    end
  end

  def action
    :__EMBEDDED_ACTION__
  end

  def instance_variable_name
    :__EMBEDDED_INSTANCE_VARIABLE_NAME__
  end

  def associations
    '__EMBEDDED_ASSOCIATIONS__'
  end
end
