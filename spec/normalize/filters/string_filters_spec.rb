require 'pathname'
require 'normalize/filters/string_filters'
require 'normalize/processor'

describe Normalize::Filters::StringFilters do
  let(:klass)         { Normalize::Filters::StringFilters }
  let(:fixtures)      { Pathname.new('spec/fixtures/filters/string_filters') }
  let(:filter)        { klass.const_get(fixture) }
  let(:processor)     { Normalize::Processor.new(filter) }

  subject do
    tokens = processor.parse(input_ruby, '<...>')
    tokens = processor.process(tokens)
    return tokens.map { |token| token.token }.join
  end

  let(:input_ruby)      { File.read(fixtures + 'input.rb') }
  let(:input_result)    { capture_stdout {  eval input_ruby } }

  let(:expected_ruby)   { File.read(fixtures + (fixture.to_s + '.rb')) }
  let(:expected_result) { capture_stdout {  eval expected_ruby } }

  shared_examples 'string filter examples' do
    it 'should perform all expected conversions, and leave everything else alone' do
      expect(subject).to eq expected_ruby
    end

    it 'should produce ruby that produces the same results as the input' do
      expect(capture_stdout { eval subject }).to eq input_result
    end
  end

  describe '::ALWAYS_DOUBLE_QUOTED_EMPTY' do
    let(:fixture) { :ALWAYS_DOUBLE_QUOTED_EMPTY }
    include_examples 'string filter examples'
  end

  describe '::ALWAYS_SINGLE_QUOTED_EMPTY' do
    let(:fixture) { :ALWAYS_SINGLE_QUOTED_EMPTY }
    include_examples 'string filter examples'
  end

  describe '::ALWAYS_DOUBLE_QUOTED_NONEMPTY' do
    let(:fixture) { :ALWAYS_DOUBLE_QUOTED_NONEMPTY }
    include_examples 'string filter examples'
  end

  describe '::PREFER_SINGLE_QUOTED_NONEMPTY' do
    let(:fixture) { :PREFER_SINGLE_QUOTED_NONEMPTY }
    include_examples 'string filter examples'
  end
end
