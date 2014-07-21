require 'normalize/filters/string_filters'
describe Normalize::Filters::StringFilters do
  subject { Normalize::Filters::StringFilters }

  let(:status) { subject.first }
  let(:output) { subject.last }

  def tokens_for_string_literal(quote, content)
    return [
      Normalize::Token[{          :kind => :on_tstring_beg,     :token => quote }],
      content ? Normalize::Token[{:kind => :on_tstring_content, :token => content }] : nil,
      Normalize::Token[{          :kind => :on_tstring_end,     :token => quote }],
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
        expect(output).to match expected
      end
    end

    context "a double-quoted empty string" do
      let(:example)  { expected.dup }

      it "should not match" do
        expect(status).to be false
      end

      it "should not be modified" do
        expect(output).to match expected
      end
    end
  end

  describe "ALWAYS_SINGLE_QUOTED_EMPTY" do
    subject { super()::ALWAYS_SINGLE_QUOTED_EMPTY.apply(example, 0) }

    let(:expected) { tokens_for_string_literal("'", nil) }

    context "a double-quoted empty string" do
      let(:example)  { tokens_for_string_literal('"', nil) }

      it "should match" do
        expect(status).to be true
      end

      it "should be modified into a single-quoted empty string" do
        expect(output).to match expected
      end
    end

    context "a single-quoted empty string" do
      let(:example)  { expected.dup }

      it "should not match" do
        expect(status).to be false
      end

      it "should not be modified" do
        expect(output).to match expected
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
          expect(output).to match expected
        end
      end

      context "when double-quoted" do
        let(:example)  { expected.dup }

        it "should not match" do
          expect(status).to be false
        end

        it "should not be modified" do
          expect(output).to match expected
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
          expect(output).to match expected
        end
      end

      context "when double-quoted" do
        # "foo \"bar\" baz"
        let(:example)  { expected.dup }

        it "should not match" do
          expect(status).to be false
        end

        it "should not be modified" do
          expect(output).to match expected
        end
      end
    end

    context "a string with single-quotes" do
      let(:expected) { tokens_for_string_literal('"', "foo's bar") }

      context "when single-quoted" do
        # 'foo\'s bar'
        let(:example)  { tokens_for_string_literal("'", "foo\\'s bar") }

        it "should match" do
          expect(status).to be true
        end

        it "should be modified into " do
          expect(output).to match expected
        end
      end

      context "when double-quoted" do
        # "foo's bar"
        let(:example)  { expected.dup }

        it "should not match" do
          expect(status).to be false
        end

        it "should not be modified" do
          expect(output).to match expected
        end
      end
    end

    context "a string with a newline in it" do
      let(:expected) { tokens_for_string_literal('"', "foo\nbar") }

      context "when single-quoted" do
        # 'foo
        # bar'
        let(:example)  { tokens_for_string_literal("'", "foo\nbar") }

        it "should match" do
          expect(status).to be true
        end

        it "should be modified into a double-quoted string" do
          expect(output).to match expected
        end
      end

      context "when double-quoted" do
        # "foo
        # bar"
        let(:example)  { expected.dup }

        it "should not match" do
          expect(status).to be false
        end

        it "should not be modified" do
          expect(output).to match expected
        end
      end
    end

    context "a single-quoted string with an ignored newline escape" do
      # Note that the \n doesn't become a newline when interpreted by Ruby.
      #
      # 'foo\nbar'
      let(:example)  { tokens_for_string_literal("'", "foo\\nbar") }
      let(:expected) { tokens_for_string_literal('"', "foo\\\\nbar") }

      it "should match" do
        expect(status).to be true
      end

      it "should be modified into double-quoted string with escapes" do
        expect(output).to match expected
      end
    end

    context "a single-quoted string with interpolation markers" do
      # Note that the #{} doesn't get interpolated when interpreted by Ruby.
      #
      # 'foo #{hash and braces} bar'
      let(:example)  { tokens_for_string_literal("'", "foo \#{hash and braces} bar") }
      let(:expected) { tokens_for_string_literal('"', "foo \\\#{hash and braces} bar") }

      it "should match" do
        expect(status).to be true
      end

      it "should be modified into double-quoted string with escapes" do
        expect(output).to match expected
      end
    end


    context "a single-quoted string with adjacent escapes" do
      # 'adjacent escaping \\\n maybe even a \\...'
      let(:example)  { tokens_for_string_literal("'", "adjacent escaping \\\\\\n maybe even a \\\\...") }
      # "adjacent escaping \\\\n maybe even a \\..."
      let(:expected) { tokens_for_string_literal('"', "adjacent escaping \\\\\\\\n maybe even a \\\\...") }

      it "should match" do
        expect(status).to be true
      end

      it "should be modified into double-quoted string with escapes" do
        expect(output).to match expected
      end
    end
  end

  describe "PREFER_SINGLE_QUOTED_NONEMPTY" do
    subject { super()::PREFER_SINGLE_QUOTED_NONEMPTY.apply(example, 0) }

    context "a string with no special characters" do
      let(:expected) { tokens_for_string_literal("'", "foo") }

      context "when double-quoted" do
        let(:example)  { tokens_for_string_literal('"', "foo") }

        it "should match" do
          expect(status).to be true
        end

        it "should be modified into a single-quoted string" do
          expect(output).to match expected
        end
      end

      context "when single-quoted" do
        let(:example)  { expected.dup }

        it "should not match" do
          expect(status).to be false
        end

        it "should not be modified" do
          expect(output).to match expected
        end
      end
    end

    context "a string with double-quotes" do
      let(:expected) { tokens_for_string_literal("'", "foo \"bar\" baz") }

      context "when double-quoted" do
        # 'foo "bar" baz'
        let(:example)  { tokens_for_string_literal('"', "foo \\\"bar\\\" baz") }

        it "should match" do
          expect(status).to be true
        end

        it "should be modified into a single-quoted string" do
          expect(output).to match expected
        end
      end

      context "when single-quoted" do
        # "foo \"bar\" baz"
        let(:example)  { expected.dup }

        it "should not match" do
          expect(status).to be false
        end

        it "should not be modified" do
          expect(output).to match expected
        end
      end
    end

    context "a string with single-quotes" do
      let(:expected) { tokens_for_string_literal('"', "foo's bar") }

      context "when single-quoted" do
        # 'foo\'s bar'
        let(:example)  { tokens_for_string_literal("'", "foo\\'s bar") }

        it "should match" do
          expect(status).to be true
        end

        it "should be modified into " do
          expect(output).to match expected
        end
      end

      context "when double-quoted" do
        # "foo's bar"
        let(:example)  { expected.dup }

        it "should not match" do
          expect(status).to be false
        end

        it "should not be modified" do
          expect(output).to match expected
        end
      end
    end

    context "a string with a newline in it" do
      let(:expected) { tokens_for_string_literal('"', "foo\nbar") }

      context "when single-quoted" do
        # 'foo
        # bar'
        let(:example)  { tokens_for_string_literal("'", "foo\nbar") }

        it "should match" do
          expect(status).to be true
        end

        it "should be modified into a double-quoted string" do
          expect(output).to match expected
        end
      end

      context "when double-quoted" do
        # "foo
        # bar"
        let(:example)  { expected.dup }

        it "should not match" do
          expect(status).to be false
        end

        it "should not be modified" do
          expect(output).to match expected
        end
      end
    end

    context "a single-quoted string with an ignored newline escape" do
      # Note that the \n doesn't become a newline when interpreted by Ruby.
      #
      # 'foo\nbar'
      let(:example)  { tokens_for_string_literal("'", "foo\\nbar") }
      let(:expected) { tokens_for_string_literal('"', "foo\\\\nbar") }

      it "should match" do
        expect(status).to be true
      end

      it "should be modified into double-quoted string with escapes" do
        expect(output).to match expected
      end
    end

    context "a single-quoted string with interpolation markers" do
      # Note that the #{} doesn't get interpolated when interpreted by Ruby.
      #
      # 'foo #{hash and braces} bar'
      let(:example)  { tokens_for_string_literal("'", "foo \#{hash and braces} bar") }
      let(:expected) { tokens_for_string_literal('"', "foo \\\#{hash and braces} bar") }

      it "should match" do
        expect(status).to be true
      end

      it "should be modified into double-quoted string with escapes" do
        expect(output).to match expected
      end
    end


    context "a single-quoted string with adjacent escapes" do
      # 'adjacent escaping \\\n maybe even a \\...'
      let(:example)  { tokens_for_string_literal("'", "adjacent escaping \\\\\\n maybe even a \\\\...") }
      # "adjacent escaping \\\\n maybe even a \\..."
      let(:expected) { tokens_for_string_literal('"', "adjacent escaping \\\\\\\\n maybe even a \\\\...") }

      it "should match" do
        expect(status).to be true
      end

      it "should be modified into double-quoted string with escapes" do
        expect(output).to match expected
      end
    end
  end

end
