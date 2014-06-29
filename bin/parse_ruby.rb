#!/usr/bin/env ruby

require_relative '../lib/normalize'

fname = ARGV.shift
outname = ARGV.shift
raise "Must specify input filename!" unless(fname && fname != '')
raise "Must specify output filename!" unless(outname && outname != '')
raise "No such file '#{fname}'!" unless(File.exist?(fname))

processor = Normalize::Processor.new

lexemes = processor.parse(File.read(fname), fname)

File.open(outname, "w") do |fh|
  fh.write(lexemes.map(&:inspect).join("\n"))
  fh.write("\n")
end
