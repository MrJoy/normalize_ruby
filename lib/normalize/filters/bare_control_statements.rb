module Normalize
  module Filters
    class BareControlStatements < Parser::Rewriter
      def on_while(node)
        cleanse_control_statement(node)
        super
      end

      def on_while_post(node)
        cleanse_control_statement(node)
        super
      end

      def on_until(node)
        cleanse_control_statement(node)
        super
      end

      def on_until_post(node)
        cleanse_control_statement(node)
        super
      end

      def on_if(node)
        cleanse_control_statement(node)
        super
      end

      def on_else(node)
        cleanse_control_statement(node)
        super
      end

      def on_elsif(node)
        cleanse_control_statement(node)
        super
      end

      def on_for(node)
        cleanse_control_statement(node)
        super
      end

      def on_case(node)
        cleanse_control_statement(node)
        super
      end

      def cleanse_control_statement(node)
        begin
          if node.children[0].type == :begin
            # If we have something of the following form, the parens are NOT
            # OPTIONAL!
            #
            # ```ruby
            # if(foo rescue bar)
            # ```
            conditional = node.children[0].children[0]
            return if !conditional || conditional.type == :rescue

            word_length           = node.loc.keyword.source.length
            word_starts_at        = node.loc.keyword.begin_pos
            condition_starts_at   = node.children[0].loc.begin.begin_pos
            effective_word_length = condition_starts_at - word_starts_at
            excess_gap_size       = 0

            if effective_word_length == word_length
              # No space, so we need to add one!
              replace node.children[0].loc.begin, ' '
            else
              # Already have some whitespace, so... yeah.
              excess_gap_size = (effective_word_length - word_length) - 1
              if excess_gap_size > 0
                # GAH!  TOO MUCH WHITESPACE!
                buffer    = node.children[0].loc.begin.source_buffer
                begin_pos = node.children[0].loc.begin.begin_pos - excess_gap_size
                end_pos   = node.children[0].loc.begin.end_pos
                range     = Parser::Source::Range.new(buffer, begin_pos, end_pos)

                remove range
                excess_gap_size += 1
              else
                # Just right -- one space.
                remove node.children[0].loc.begin
                excess_gap_size = 1
              end
            end
            replace node.children[0].loc.end, ' ' * (excess_gap_size + 1)
          end
        rescue
        end
      end
    end
  end
end
