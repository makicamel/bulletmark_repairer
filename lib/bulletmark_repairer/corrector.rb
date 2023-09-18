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
    BulletmarkRepairer.markers.patching_marker.line_no
  end

  def associations
    BulletmarkRepairer.markers.patching_marker.associations
  end
end
