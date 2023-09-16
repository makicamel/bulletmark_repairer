# frozen_string_literal: true

class Corrector < Parser::TreeRewriter
  def on_send(node)
    if node.location.expression.line <= line_no && line_no <= node.location.expression.last_line
      insert_after node.children[0].location.expression, ".includes(#{associations})"
    end

    super
  end

  private

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
