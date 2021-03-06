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
    # NOTE: Do *not* run with --modify until issue below is fixed!
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
