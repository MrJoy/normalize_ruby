require 'normalize/filters/string_filters'
describe Normalize::Filters::StringFilters do
  def tokens_for_string_literal(quote, content)
    return [
      {          :kind => :on_tstring_beg,     :token => quote},
      content ? {:kind => :on_tstring_content, :token => content} : nil,
      {          :kind => :on_tstring_end,     :token => quote},
    ].reject { |token| token.nil? }
  end

  # "foo"
  let(:double_quoted_string) do
    tokens_for_string_literal('"', "foo")
  end

  # 'foo'
  let(:single_quoted_string) do
    tokens_for_string_literal("'", "foo \"bar\" baz")
  end


  # "foo \"bar\" baz"
  let(:double_quoted_string_with_double_quotes) do
    tokens_for_string_literal('"', "foo \\\"bar\\\" baz")
  end

  # 'foo "bar" baz'
  let(:single_quoted_string_with_double_quotes) do
    tokens_for_string_literal('"', "foo \"bar\" baz")
  end


  # "foo's bar"
  let(:double_quoted_string_with_single_quote) do
    tokens_for_string_literal('"', "foo's bar")
  end

  # 'foo\'s bar'
  let(:single_quoted_string_with_single_quote) do
    tokens_for_string_literal('"', "foo\\'s bar")
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

  describe "ALWAYS_DOUBLE_QUOTED_EMPTY" do
    subject do
      Normalize::Filters::StringFilters::ALWAYS_DOUBLE_QUOTED_EMPTY.apply(example, 0)
    end

    context "a double-quoted empty string" do
      let(:example) { tokens_for_string_literal('"', nil) }

      it "should not match the input" do
        expect(subject.first).to be false
      end

      it "should not modify input" do
        expect(subject.last).to eq tokens_for_string_literal('"', nil)
      end
    end

    context "a single-quoted empty string" do
      let(:example) { tokens_for_string_literal("'", nil) }

      it "should match the input" do
        expect(subject.first).to be true
      end

      it "should be modified into a double-quoted empty string" do
        expect(subject.last).to eq tokens_for_string_literal('"', nil)
      end
    end
  end

  describe "ALWAYS_DOUBLE_QUOTED_NONEMPTY" do
  end
end
