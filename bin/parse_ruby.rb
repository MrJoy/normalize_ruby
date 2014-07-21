#!/usr/bin/env ruby

require_relative '../lib/normalize'

puts Normalize::Processor.
  new.
  parse(STDIN.readlines.join, '<stdin>').
  map(&:ignore_position).
  map(&:to_s).
  join("\n")
