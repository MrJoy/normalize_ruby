require 'pathname'
# require 'normalize/filters/whitespace_filters'
# require 'normalize/processor'

# describe Normalize::Filters::WhitespaceFilters do
#   let(:klass)         { Normalize::Filters::WhitespaceFilters }
#   let(:fixtures)      { Pathname.new('spec/fixtures/filters/whitespace_filters') }
#   let(:filter)        { klass.const_get(fixture) }
#   let(:processor)     { Normalize::Processor.new(filter) }

#   subject do
#     tokens = processor.parse(input_ruby, '<...>')
#     tokens = processor.process(tokens)
#     return tokens.map { |token| token.token }.join
#   end

#   let(:input_ruby)      { File.read(fixtures + 'input.rb') }
#   let(:expected_ruby)   { File.read(fixtures + (fixture.to_s + '.rb')) }

#   shared_examples 'string filter examples' do
#     it 'should perform all expected conversions, and leave everything else alone' do
#       expect(subject).to eq expected_ruby
#     end
#   end

#   describe '::STRIP_TRAILING_WHITESPACE_FROM_STATEMENTS' do
#     let(:fixture) { :STRIP_TRAILING_WHITESPACE_FROM_STATEMENTS }
#     include_examples 'string filter examples'
#   end

#   describe '::STRIP_TRAILING_WHITESPACE_FROM_COMMENTS' do
#     let(:fixture) { :STRIP_TRAILING_WHITESPACE_FROM_COMMENTS }
#     include_examples 'string filter examples'
#   end
# end
