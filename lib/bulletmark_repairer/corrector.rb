# frozen_string_literal: true

class Corrector < Parser::TreeRewriter
  def on_def(node)
    return if patched?

    node.children.each { |child_node| insert_includes(node: child_node) }
  end

  private

  def patched?
    @patched ||= false
  end

  def insert_includes(node:)
    return if patched?
    return if !node.respond_to?(:children) || node.children.empty?
    return unless node.location.expression.line <= line_no && line_no <= node.location.expression.last_line

    if node.children.last.in?(%i[each map])
      insert_after node.children[0].location.expression, ".includes(#{associations})"
      @patched = true
    else
      node.children.each { |child_node| insert_includes(node: child_node) }
    end
  end

  def line_no
    return @line_no if @line_no

    callers = BulletmarkRepairer.markers.last.instance_variable_get(:@callers)
    yield_index = callers.index { |caller| caller.scan(%r{\A/[./\w]+:(\d+):in `block in [\w]+'\z}).flatten.presence }
    @line_no = callers[yield_index + 1].scan(%r{\A/[./\w]+:(\d+):in `[\w]+'\z}).flatten.first.to_i
  end

  def associations
    BulletmarkRepairer.markers.map do |marker|
      marker.instance_variable_get(:@associations)
    end.flatten
  end
end
