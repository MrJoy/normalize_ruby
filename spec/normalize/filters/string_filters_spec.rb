require 'pathname'
require 'normalize/filters/string_filters'
require 'normalize/processor'

describe Normalize::Filters::StringFilters do
  let(:klass)     { Normalize::Filters::StringFilters }
  let(:fixtures)  { Pathname.new('spec/fixtures/filters/string_filters') }
  let(:processor) { Normalize::Processor.new(*Array(filters)) }

  subject do
    tokens = processor.parse(input_ruby, '<...>')
    tokens = processor.process(tokens)
    return tokens.map { |token| token.token }.join
  end

  let(:input_ruby) { File.read(fixtures + 'input.rb') }
  let(:input_result) do
    capture_stdout do
      eval input_ruby
    end
  end

  describe '::PREFER_SINGLE_QUOTED_NONEMPTY' do
    let(:filters) { klass::PREFER_SINGLE_QUOTED_NONEMPTY }
    let(:expected_ruby) { File.read(fixtures + 'PREFER_SINGLE_QUOTED_NONEMPTY.rb') }
    let(:expected_result) do
      capture_stdout do
        eval expected_ruby
      end
    end

    it 'should perform all expected conversions, and leave everything else alone' do
      expect(subject).to eq expected_ruby
    end

    it 'should produce ruby that produces the same results as the input' do
      expect(capture_stdout { eval subject }).to eq input_result
    end
  end
end
