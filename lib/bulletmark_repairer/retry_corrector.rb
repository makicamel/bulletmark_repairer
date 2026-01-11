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

  def includes_token
    @includes_token ||= ".includes(#{associations})"
  end

  def inserted?(parent_node)
    parent_node.location.expression.source.include?(includes_token)
  end

  def insert_includes(node:)
    return if patched?
    return if !node.respond_to?(:children) || node.children.empty?
    return unless line_no.between?(node.location.expression.line, node.location.expression.last_line)

    if node.type == :begin
      node.children.each { |child_node| insert_includes(node: child_node) }
    else
      node.children.each do |child_node|
        execute_insert_includes(node: child_node, parent_node: node)
      end
    end
  end

  def execute_insert_includes(node:, parent_node:)
    return unless node.respond_to?(:children)
    return if patched?

    node.children.each do |child_node|
      if child_node.is_a?(Symbol)
        if BulletmarkRepairer::Thread.correctable_method?(child_node) && !inserted?(parent_node)
          insert_after node.location.expression, includes_token
          @patched = true
        end
      else
        execute_insert_includes(node: child_node, parent_node: node)
      end
    end
  end

  def line_no
    __EMBEDDED_LINE_NO__
  end

  def associations
    '__EMBEDDED_ASSOCIATIONS__'
  end
end
