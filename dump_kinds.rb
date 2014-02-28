#!/usr/bin/env ruby

require 'ripper'

fname = ARGV.shift
lexemes = Ripper.lex(File.read(fname), fname)

puts lexemes.map { |((line,col),kind,token)| kind }.join("\n")
