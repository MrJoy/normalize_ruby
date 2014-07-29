class Undo < Parser::Rewriter
  def on_while(node)
    remove_delimiter(node, 'do')
    super
  end

  def on_until(node)
    remove_delimiter(node, 'do')
    super
  end

  def on_if(node)
    remove_delimiter(node, 'then')
    super
  end

  def remove_delimiter(node, delimiter)
    begin
      if node.loc.begin && node.loc.begin.is?(delimiter)
        remove node.loc.begin
      end
    rescue
      # Just ignore shit if things go wrong.
    end
  end
end
