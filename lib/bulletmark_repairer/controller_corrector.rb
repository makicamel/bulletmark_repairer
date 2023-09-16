# frozen_string_literal: true

class ControllerCorrector < Parser::TreeRewriter
  def on_def(node)
    return if patched?
    return unless node.children.first == BulletmarkRepairer.target_method

    node.children.reverse.each { |child_node| insert_includes(node: child_node) }
  end

  private

  def patched?
    @patched ||= false
  end

  def insert_includes(node:)
    return if patched?

    type, ivname = node.to_sexp_array.take(2)

    if type == :ivasgn && ivname == instance_variable_name
      insert_after node.children.last.location.expression, ".includes(#{associations})"
      @patched = true
    else
      node.children.reverse.each { |child_node| insert_includes(node: child_node) }
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
