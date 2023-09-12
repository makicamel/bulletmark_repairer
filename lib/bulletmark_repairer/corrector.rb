# frozen_string_literal: true

class Corrector < Parser::TreeRewriter
  def on_send(node)
    insert_includes(node)
    super
  end

  private

  def insert_includes(node)
    return unless node.loc.expression.line == line_no - 1 && node.children[0]

    insert_after node.children[0].location.expression, ".includes(#{associations})"
  end

  def line_no
    return @line_no if @line_no

    callers = BulletmarkRepairer.notifications.last.instance_variable_get(:@callers)
    callers.any? { |caller| caller.scan(%r{\A/[./\w]+:(\d+):in `[\w]+'\z}).flatten.presence }
    @line_no = Regexp.last_match(1).to_i
  end

  def associations
    BulletmarkRepairer.notifications.map do |notification|
      notification.instance_variable_get(:@associations)
    end.flatten
  end
end
