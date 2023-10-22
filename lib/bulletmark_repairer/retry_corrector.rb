# frozen_string_literal: true

class RetryCorrector < Parser::TreeRewriter
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

    if node.type == :begin
      node.children.each { |child_node| insert_includes(node: child_node) }
    else
      inserted = ".includes(#{associations})"
      return if node.location.expression.source.include?(inserted)

      insert_after node.location.expression, ".includes(#{associations})"
      @patched = true
    end
  end

  def line_no
    __EMBEDDED_LINE_NO__
  end

  def associations
    '__EMBEDDED_ASSOCIATIONS__'
  end
end
