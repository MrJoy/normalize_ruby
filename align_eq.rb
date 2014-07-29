class AlignEq < Parser::Rewriter
  def on_begin(node)
    eq_nodes = []

    node.children.each do |child_node|
      if assignment?(child_node)
        eq_nodes << child_node
      elsif eq_nodes.any?
        align(eq_nodes)
        eq_nodes = []
      end
    end

    align(eq_nodes)

    super
  end

  def align(eq_nodes)
    aligned_column = eq_nodes.
      map { |node| node.loc.operator.column }.
      max

    eq_nodes.each do |node|
      if (column = node.loc.operator.column) < aligned_column
        insert_before node.loc.operator, ' ' * (aligned_column - column)
      end
    end
  end
end
