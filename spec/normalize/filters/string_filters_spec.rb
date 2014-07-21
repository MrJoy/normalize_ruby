require 'ostruct'
require 'normalize/filters/string_filters'
require 'normalize/processor'

describe Normalize::Filters::StringFilters do
  subject { filter.apply(example) }

  let(:klass)   { Normalize::Filters::StringFilters }
  let(:status)  { subject.first }
  let(:output)  { subject.last }

  let(:fixture)       { fixtures[index] }
  let(:example)       { examples[index] }
  let(:expected)      { expectations[index] }

  let(:raw_strings) do
    processor = Normalize::Processor.new
    File.
      read('spec/fixtures/filters/string_filters/raw_strings.txt').
      split(/\|/).
      map(&:rstrip).
      map do |str|
        single_quoted = "'" + str.gsub(/\\/, '\\\\').gsub(/'/, '\\\\\'') + "'"
        double_quoted = str.inspect
        single_quoted = processor.parse(single_quoted, '.../raw_strings.txt').map(&:ignore_position)
        double_quoted = processor.parse(double_quoted, '.../raw_strings.txt').map(&:ignore_position)
        OpenStruct.new(
          literal:        str,
          single_quoted:  single_quoted,
          double_quoted:  double_quoted,
        )
      end
  end

  let(:all_strings) do
    raw_strings.map(&:single_quoted) +
    raw_strings.map(&:double_quoted)
  end

  let(:empty)             { raw_strings[0] }
  let(:simple)            { raw_strings[1] }
  let(:single_quote)      { raw_strings[2] }
  let(:double_quote)      { raw_strings[3] }
  let(:hash_brace)        { raw_strings[4] }
  let(:hash_hash)         { raw_strings[5] }
  let(:hash_gvar)         { raw_strings[6] }
  let(:hash_ivar)         { raw_strings[7] }
  let(:hash_cvar)         { raw_strings[8] }
  let(:adjacent_escapes)  { raw_strings[9] }
  let(:bogus_escape)      { raw_strings[10] }
  let(:newline)           { raw_strings[11] }

  shared_examples 'negative matches' do
    context 'anything else' do
      it("doesn't match, or modify anything") do
        (all_strings - examples).each do |counter_example|
          expect(filter.apply(counter_example)).to eq [false, counter_example]
        end
      end
    end
  end

  shared_examples 'positive match' do
    it('matches')     { expect(status).to be true }
    it('is modified') { expect(output).to match expected }
  end

  describe '::ALWAYS_DOUBLE_QUOTED_EMPTY' do
    let(:filter)        { klass::ALWAYS_DOUBLE_QUOTED_EMPTY }
    let(:fixtures)      { [empty] }
    let(:examples)      { fixtures.map(&:single_quoted) }
    let(:expectations)  { fixtures.map(&:double_quoted) }

    context 'an empty, single-quoted string' do
      let(:index) { 0 }
      include_examples 'positive match'
    end

    include_examples 'negative matches'
  end

  describe '::ALWAYS_SINGLE_QUOTED_EMPTY' do
    let(:filter)        { klass::ALWAYS_SINGLE_QUOTED_EMPTY }
    let(:fixtures)      { [empty] }
    let(:examples)      { fixtures.map(&:double_quoted) }
    let(:expectations)  { fixtures.map(&:single_quoted) }

    context 'an empty, double-quoted string' do
      let(:index) { 0 }
      include_examples 'positive match'
    end

    include_examples 'negative matches'
  end

  describe '::ALWAYS_DOUBLE_QUOTED_NONEMPTY' do
    let(:filter)        { klass::ALWAYS_DOUBLE_QUOTED_NONEMPTY }
    let(:fixtures)      do
      [
        simple, single_quote, double_quote, hash_brace, hash_hash, hash_gvar,
        hash_ivar, hash_cvar, adjacent_escapes, bogus_escape, newline
      ]
    end
    let(:examples)      { fixtures.map(&:single_quoted) }
    let(:expectations)  { fixtures.map(&:double_quoted) }

    context 'a simple, single-quoted string' do
      let(:index) { 0 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing single-quotes' do
      let(:index) { 1 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing double-quotes' do
      let(:index) { 2 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing `#{`' do
      let(:index) { 3 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing `##`' do
      let(:index) { 4 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing `#$`' do
      let(:index) { 5 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing `#@`' do
      let(:index) { 6 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing `#@@`' do
      let(:index) { 7 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing adjacent escapes' do
      let(:index) { 8 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing invalid escapes' do
      let(:index) { 9 }
      include_examples 'positive match'
    end

    include_examples 'negative matches'
  end

  describe '::PREFER_SINGLE_QUOTED_NONEMPTY' do
    let(:filter)        { klass::PREFER_SINGLE_QUOTED_NONEMPTY }
    let(:fixtures)      do
      [
        simple, double_quote, hash_brace, hash_hash, hash_gvar, hash_ivar, hash_cvar
      ]
      # single_quote, double_quote, hash_brace, hash_hash, hash_gvar,
      #   hash_ivar, hash_cvar, bogus_escape, newline, adjacent_escapes
    end
    let(:examples)      { fixtures.map(&:double_quoted) }
    let(:expectations)  { fixtures.map(&:single_quoted) }

    context 'a simple, single-quoted string' do
      let(:index) { 0 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing double quotes' do
      let(:index) { 1 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing `#{`' do
      let(:index) { 2 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing `##`' do
      let(:index) { 3 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing `#$`' do
      let(:index) { 4 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing `#@`' do
      let(:index) { 5 }
      include_examples 'positive match'
    end

    context 'a single-quoted string containing `#@@`' do
      let(:index) { 6 }
      include_examples 'positive match'
    end

    include_examples 'negative matches'
  end
end
