#!/usr/bin/env ruby

require_relative '../lib/normalize'

puts Normalize::Processor.
  new.
  parse(STDIN.readlines.join, "<stdin>").
  map(&:inspect).
  join("\n")
