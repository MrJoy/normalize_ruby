class Undo < Parser::Rewriter
  # def on_while(node)
  #   remove_delimiter(node, 'do')
  #   super
  # end

  # def on_until(node)
  #   remove_delimiter(node, 'do')
  #   super
  # end

  def on_if(node)
    # remove_delimiter(node, 'then')
    begin
      if(node.children[0].loc.begin)
        replace node.children[0].loc.begin, ' '
        remove node.children[0].loc.end
      end
    rescue
    end
    super
  end

  def remove_delimiter(node, delimiter)
    begin
      # TODO: Figure out how to fix this for problematic cases.
      # TODO: http://whitequark.org/blog/2013/04/26/lets-play-with-ruby-code/
      # TODO: `bodies.compact.none? { |body| body.loc.line == condition.loc.line }`
      if node.loc.begin && node.loc.begin.is?(delimiter)
        remove node.loc.begin
      end
    rescue
      # Just ignore shit if things go wrong.
    end
  end
end
