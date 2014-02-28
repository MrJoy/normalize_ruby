#!/usr/bin/env ruby

require 'ripper'
require 'sorcerer'

fname = ARGV.shift
sexp = Ripper.sexp(File.read(fname), fname)
tokens = Ripper.tokenize(File.read(fname))

#tokens = tokens.map
puts tokens.join
# puts Sorcerer.source(sexp, indent: true)
