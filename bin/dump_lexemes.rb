#!/usr/bin/env ruby

require 'ripper'

fname = ARGV.shift
lexemes = Ripper.lex(File.read(fname), fname)

puts lexemes.map { |*lexeme| lexeme.flatten.inspect }.join("\n")
