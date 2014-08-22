require 'pathname'
require 'normalize/runner'
require 'normalize/filters/bare_control_statements'

describe Normalize::Filters::BareControlStatements do
  let(:klass)         { Normalize::Filters::BareControlStatements }
  let(:fixtures)      { Pathname.new('spec/fixtures/filters/bare_control_statements') }
  let(:filter)        { klass.const_get(fixture) }
  # let(:processor)     { Normalize::Processor.new(filter) }

  subject do
    tokens = processor.parse(input_ruby, '<...>')
    tokens = processor.process(tokens)
    return tokens.map { |token| token.token }.join
  end

  let(:input_ruby)      { File.read(fixtures + 'input.rb') }
  let(:expected_ruby)   { File.read(fixtures + (fixture.to_s + '.rb')) }

  shared_examples 'string filter examples' do
    it 'should perform all expected conversions, and leave everything else alone' do
      expect(subject).to eq expected_ruby
    end
  end

  describe '::PREFER_NO_PARENS_ON_CONTROL_KEYWORDS' do
    let(:fixture) { :PREFER_NO_PARENS_ON_CONTROL_KEYWORDS }
    include_examples 'string filter examples'
  end
end
