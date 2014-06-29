require 'normalize/filters/string_filters'
describe Normalize::Filters::StringFilters do
  subject { Normalize::Filters::StringFilters }

  def tokens_for_string_literal(quote, content)
    return [
      {          :kind => :on_tstring_beg,     :token => quote },
      content ? {:kind => :on_tstring_content, :token => content } : nil,
      {          :kind => :on_tstring_end,     :token => quote },
    ].reject { |token| token.nil? }
  end

  describe "ALWAYS_DOUBLE_QUOTED_EMPTY" do
    subject { super()::ALWAYS_DOUBLE_QUOTED_EMPTY.apply(example, 0) }

    context "a single-quoted empty string" do
      let(:example)  { tokens_for_string_literal("'", nil) }
      let(:expected) { tokens_for_string_literal('"', nil) }

      it "should match" do
        expect(subject.first).to be true
      end

      it "should be modified into a double-quoted empty string" do
        expect(subject.last).to eq expected
      end
    end

    context "a double-quoted empty string" do
      let(:example)  { tokens_for_string_literal('"', nil) }
      let(:expected) { tokens_for_string_literal('"', nil) }

      it "should not match" do
        expect(subject.first).to be false
      end

      it "should not be modified" do
        expect(subject.last).to eq expected
      end
    end
  end

  describe "ALWAYS_DOUBLE_QUOTED_NONEMPTY" do
    subject { super()::ALWAYS_DOUBLE_QUOTED_NONEMPTY.apply(example, 0) }

    context "a string with no special characters" do
      context "when single-quoted" do
        let(:example)  { tokens_for_string_literal("'", "foo") }
        let(:expected) { tokens_for_string_literal('"', "foo") }

        it "should match" do
          expect(subject.first).to be true
        end

        it "should be modified into a double-quoted string" do
          expect(subject.last).to eq expected
        end
      end

      context "when double-quoted" do
        let(:example)  { tokens_for_string_literal('"', "foo") }
        let(:expected) { tokens_for_string_literal('"', "foo") }

        it "should not match" do
          expect(subject.first).to be false
        end

        it "should not be modified" do
          expect(subject.last).to eq expected
        end
      end
    end

    context "a string with double-quotes" do
      context "when single-quoted" do
        # 'foo "bar" baz'
        let(:example)  { tokens_for_string_literal("'", "foo \"bar\" baz") }
        let(:expected) { tokens_for_string_literal('"', "foo \\\"bar\\\" baz") }

        it "should match" do
          expect(subject.first).to be true
        end

        it "should be modified into " do
          expect(subject.last).to eq expected
        end
      end

      context "when double-quoted" do
        # "foo \"bar\" baz"
        let(:example)  { tokens_for_string_literal('"', "foo \\\"bar\\\" baz") }
        let(:expected) { tokens_for_string_literal('"', "foo \\\"bar\\\" baz") }

        it "should not match" do
          expect(subject.first).to be false
        end

        it "should not be modified" do
          expect(subject.last).to eq expected
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
