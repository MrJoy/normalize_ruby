#!/usr/bin/env ruby

require 'ripper'

fname = ARGV.shift
lexemes = Ripper.lex(File.read(fname), fname)

File.open(fname, "w") do |fh|
  fh.write tokens.join
end
