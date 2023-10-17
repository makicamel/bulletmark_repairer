# frozen_string_literal: true

class Corrector < Parser::TreeRewriter
  def on_def(node)
    return if patched?

    node.children.each { |child_node| insert_includes(node: child_node) }
    return if patched?

    node.children.each { |child_node| insert_includes_for_vasgn(node: child_node, type: :ivasgn) }
    return if patched?

    node.children.each { |child_node| insert_includes_for_vasgn(node: child_node, type: :lvasgn) }
  end

  private

  def patched?
    @patched ||= false
  end

  def insert_includes(node:)
    return if patched?
    return if !node.respond_to?(:children) || node.children.empty?
    return unless node.location.expression.line <= line_no && line_no <= node.location.expression.last_line

    # TODO: Patch Enumerable methods other than each and map
    if node.children.last.in?(%i[each map])
      inserted = ".includes(#{associations})"
      unless node.location.expression.source.include?(inserted)
        insert_after node.children[0].location.expression, ".includes(#{associations})"
        @patched = true
      end
    else
      node.children.each { |child_node| insert_includes(node: child_node) }
    end
  end

  def insert_includes_for_vasgn(node:, type:)
    return if patched?
    return if !node.respond_to?(:children) || node.children.empty?
    return unless node.location.expression.line <= line_no && line_no <= node.location.expression.last_line

    if node.type == type
      inserted = ".includes(#{associations})"
      unless node.location.expression.source.include?(inserted)
        insert_after node.children.last.location.expression, ".includes(#{associations})"
        @patched = true
      end
    else
      node.children.each { |child_node| insert_includes_for_vasgn(node: child_node, type: type) }
    end
  end

  def line_no
    __EMBEDDED_LINE_NO__
  end

  def associations
    '__EMBEDDED_ASSOCIATIONS__'
  end
end
