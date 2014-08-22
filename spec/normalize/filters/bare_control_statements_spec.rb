require 'pathname'
require 'normalize/runner'
require 'normalize/filters/bare_control_statements'
require_relative '../../runner_helper'

describe Normalize::Filters::BareControlStatements do
  let(:processor)     { Normalize::TestRunner.new(Normalize::Filters::BareControlStatements) }
  let(:fixtures)      { Pathname.new('spec/fixtures/filters/bare_control_statements') }

  it 'prefers no optional parens on control statements' do
    fixture       = 'PREFER_NO_PARENS_ON_CONTROL_KEYWORDS'
    input_ruby    = File.read(fixtures + 'input.rb')
    expected_ruby = File.read(fixtures + (fixture + '.rb'))

    result = processor.process(input_ruby)

    expect(result).to eq expected_ruby
  end
end
