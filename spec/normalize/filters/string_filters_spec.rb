require 'normalize/filters/string_filters'
describe Normalize::Filters::StringFilters do
  subject { Normalize::Filters::StringFilters }

  let(:status) { subject.first }
  let(:output) { subject.last }

  def tokens_for_string_literal(quote, content)
    return [
      {          :kind => :on_tstring_beg,     :token => quote },
      content ? {:kind => :on_tstring_content, :token => content } : nil,
      {          :kind => :on_tstring_end,     :token => quote },
    ].reject { |token| token.nil? }
  end

  describe "ALWAYS_DOUBLE_QUOTED_EMPTY" do
    subject { super()::ALWAYS_DOUBLE_QUOTED_EMPTY.apply(example, 0) }

    let(:expected) { tokens_for_string_literal('"', nil) }

    context "a single-quoted empty string" do
      let(:example)  { tokens_for_string_literal("'", nil) }

      it "should match" do
        expect(status).to be true
      end

      it "should be modified into a double-quoted empty string" do
        expect(output).to eq expected
      end
    end

    context "a double-quoted empty string" do
      let(:example)  { expected.dup }

      it "should not match" do
        expect(status).to be false
      end

      it "should not be modified" do
        expect(output).to eq expected
      end
    end
  end

  describe "ALWAYS_DOUBLE_QUOTED_NONEMPTY" do
    subject { super()::ALWAYS_DOUBLE_QUOTED_NONEMPTY.apply(example, 0) }

    context "a string with no special characters" do
      let(:expected) { tokens_for_string_literal('"', "foo") }

      context "when single-quoted" do
        let(:example)  { tokens_for_string_literal("'", "foo") }

        it "should match" do
          expect(status).to be true
        end

        it "should be modified into a double-quoted string" do
          expect(output).to eq expected
        end
      end

      context "when double-quoted" do
        let(:example)  { expected.dup }

        it "should not match" do
          expect(status).to be false
        end

        it "should not be modified" do
          expect(output).to eq expected
        end
      end
    end

    context "a string with double-quotes" do
      let(:expected) { tokens_for_string_literal('"', "foo \\\"bar\\\" baz") }

      context "when single-quoted" do
        # 'foo "bar" baz'
        let(:example)  { tokens_for_string_literal("'", "foo \"bar\" baz") }

        it "should match" do
          expect(status).to be true
        end

        it "should be modified into a double-quoted string with escapes" do
          expect(output).to eq expected
        end
      end

      context "when double-quoted" do
        # "foo \"bar\" baz"
        let(:example)  { expected.dup }

        it "should not match" do
          expect(status).to be false
        end

        it "should not be modified" do
          expect(output).to eq expected
        end
      end
    end



  # "foo
  # bar"
  let(:double_quoted_string_with_newline) do
    tokens_for_string_literal('"', "foo\nbar")
  end

  # 'foo
  # bar'
  let(:single_quoted_string_with_newline) do
    tokens_for_string_literal("'", "foo\nbar")
  end



  # Note that the \n doesn't become a newline when interpreted by Ruby.
  #
  # 'foo\nbar'
  let(:single_quoted_string_with_ignored_newline) do
    tokens_for_string_literal("'", "foo\\nbar")
  end

  # Note that the #{} doesn't get interpolated when interpreted by Ruby.
  #
  # 'foo #{hash and braces} bar'
  let(:single_quoted_string_with_interpolation_markers) do
    tokens_for_string_literal("'", "foo \#{hash and braces} bar")
  end

  # 'adjacent escaping \\\n maybe even a \\...'
  let(:single_quoted_string_with_adjacent_escapes) do
    tokens_for_string_literal("'", "adjacent escaping \\\\\\n maybe even a \\\\...")
  end

  end
end
