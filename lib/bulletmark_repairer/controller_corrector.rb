# frozen_string_literal: true

class ControllerCorrector < Parser::TreeRewriter
  def on_class(class_node)
    node = class_node.children.last
    node
      .children
      .select do |child_node|
        type, identifier = child_node.to_sexp_array.take(2)
        target_nodes[identifier] = child_node if type == :def
      end
    action_node = target_nodes.delete(BulletmarkRepairer.action)
    insert_includes(node: action_node)
  end

  private

  def patched?
    @patched ||= false
  end

  def target_nodes
    @target_nodes ||= {}
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

  def instance_variable_name
    return @instance_variable_name if @instance_variable_name

    callers = BulletmarkRepairer.notifications.last.instance_variable_get(:@callers)
    view_file, yield_index = callers.last.scan(%r{\A(/[./\w]+):\d+:in `[\w]+'\z}).flatten
    File.open(view_file) do |f|
      source = f.readlines[yield_index.to_i]
      @instance_variable_name = source.scan(/\b?(@[\w]+)\b?/).flatten.last.to_sym
    end
  end

  def associations
    BulletmarkRepairer.notifications.map do |notification|
      notification.instance_variable_get(:@associations)
    end.flatten
  end
end
