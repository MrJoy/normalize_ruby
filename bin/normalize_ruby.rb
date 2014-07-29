#!/usr/bin/env ruby

require_relative '../lib/normalize'

show_help               = false
fname                   = nil
outname                 = nil
clean_whitespace        = false
convert_quotes          = nil
convert_control_parens  = nil

while ARGV.length > 0
  term = ARGV.shift
  if term == '-?' || term == '--help'
    show_help = true
    ARGV.clear
  elsif term =~ /\A--/
    case term
    when '--clean-whitespace'
      clean_whitespace = true
    when '--prefer-single-quotes'
      convert_quotes = :single
    when '--prefer-double-quotes'
      convert_quotes = :double
    when '--prefer-bare-controls'
      convert_control_parens = :bare
    when '--prefer-wrapped-controls'
      convert_control_parens = :wrapped
    end
  elsif fname.nil?
    fname = term
  elsif outname.nil?
    outname = term
  else
    raise "Got unexpected extra parameter: #{term}"
  end
end

if (fname.nil? && outname.nil?) || show_help
  puts "Usage: normalize_ruby <infile> [<outfile>] [--clean-whitespace]
  [--prefer-single-quotes|--prefer-double-quotes]
  [--prefer-bare-controls|--prefer-wrapped-controls]"
  puts
  puts '    <infile> - File to read.  Specify `-` to read STDIN.'
  puts '               Note that <outfile> is ignored when reading from STDIN.'
  puts '    <outfile> - File to write.  Defaults to <infile>.'
  puts
  puts '    --clean-whitespace            Trim trailing whitespace from ends of lines'
  puts '    --prefer-single-quotes        Where possible, coerce string literals to'
  puts '                                  be single-quoted.'
  puts '    --prefer-double-quotes        Coerce string literals to be double-quoted.'
  puts '    --prefer-bare-controls        Remove parens on control-flow statements.'
  puts '                                  (PARTIALLY IMPLEMENTED.)'
  puts '    --prefer-wrapped-controls     Add parens to control-flow statements if'
  puts '                                  absent.  (UNIMPLEMENTED.)'
  exit 1
end

raise 'Must specify filename!' unless fname && fname != '' || fname == '-'
raise "No such file '#{fname}'!" unless File.exist?(fname) || fname == '-'
outname = fname unless outname && outname != ''

filters = []
if clean_whitespace
  filters += [
    Normalize::Filters::WhitespaceFilters::STRIP_TRAILING_WHITESPACE_FROM_STATEMENTS,
    Normalize::Filters::WhitespaceFilters::STRIP_TRAILING_WHITESPACE_FROM_COMMENTS,
  ]
end

if convert_quotes == :single
  filters += [
    Normalize::Filters::StringFilters::ALWAYS_SINGLE_QUOTED_EMPTY,
    Normalize::Filters::StringFilters::PREFER_SINGLE_QUOTED_NONEMPTY,
  ]
elsif convert_quotes == :double
  filters += [
    Normalize::Filters::StringFilters::ALWAYS_DOUBLE_QUOTED_EMPTY,
    Normalize::Filters::StringFilters::ALWAYS_DOUBLE_QUOTED_NONEMPTY,
  ]
end
if convert_control_parens == :bare
  filters += [
    Normalize::Filters::KeywordFilters::PREFER_NO_PARENS_ON_CONTROL_KEYWORDS,
  ]
elsif convert_control_parens == :wrapped
  raise 'Sorry, --prefer-wrapped-controls is not implemented yet!'
end

processor = Normalize::Processor.new(*filters)

if fname == '-'
  contents        = STDIN.read
  effective_fname = '<stdin>'
else
  contents        = File.read(fname)
  effective_fname = fname
end
result = processor.
  parse(contents, effective_fname).
  process.
  to_s

if clean_whitespace
  # Ensure exactly one trailing newline:
  #
  # TODO: We should do newline normalization as part of whitespace-related
  # TODO: rules, and allow configurability.
  result = result.rstrip + "\n"
end

if fname == '-'
  puts result
else
  # Only muddle with the file if we actually changed something, otherwise
  # leave mtime et al alone.
  if result != contents
    File.open(outname, 'w') do |fh|
      fh.write(result)
    end
  end
end
