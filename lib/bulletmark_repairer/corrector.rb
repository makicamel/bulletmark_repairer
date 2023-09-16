# frozen_string_literal: true

class Corrector < Parser::TreeRewriter
  def on_def(node)
    method = node.children.first
    patched_methods[method] = nil
    node.children.each { |child_node| insert_include(node: child_node, method:) }

    super
  end

  private

  def patched_methods
    @patched_methods ||= {}
  end

  def insert_include(node:, method:)
    return if patched_methods[method]
    return if !node.respond_to?(:children) || node.children.empty?
    return unless node.location.expression.line <= line_no && line_no <= node.location.expression.last_line

    if node.children.last.in?(%i[each map])
      insert_after node.children[0].location.expression, ".includes(#{associations})"
      patched_methods[method] = true
    else
      node.children.each { |child_node| insert_include(node: child_node, method:) }
    end
  end

  def line_no
    return @line_no if @line_no

    callers = BulletmarkRepairer.notifications.last.instance_variable_get(:@callers)
    yield_index = callers.index { |caller| caller.scan(%r{\A/[./\w]+:(\d+):in `block in [\w]+'\z}).flatten.presence }
    @line_no = callers[yield_index + 1].scan(%r{\A/[./\w]+:(\d+):in `[\w]+'\z}).flatten.first.to_i
  end

  def associations
    BulletmarkRepairer.notifications.map do |notification|
      notification.instance_variable_get(:@associations)
    end.flatten
  end
end
