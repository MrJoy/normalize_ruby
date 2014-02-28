#!/usr/bin/env ruby

require 'ripper'

fname = ARGV.shift
raise "Must specify filename!" unless(fname && fname != '')
raise "No such file '#{fname}'!" unless(File.exist?(fname))

tokens = Ripper.
  lex(File.read(fname), fname).
  map do |((line_no, col_no), kind, token)|
    { line: line_no, col: col_no, kind: kind, token: token }
  end

RULES=[
  [
    # MATCH: Empty single-quoted string.
    # REPLACEMENT: Empty double-quoted string.
    [
      { kind: :on_tstring_beg,      token: "'" },
      { kind: :on_tstring_end,      token: "'" },
    ],
    proc do |tokens|
      [
        { kind: :on_tstring_beg,      token: "\"" },
        { kind: :on_tstring_end,      token: "\"" },
      ]
    end
  ],
  [
    # MATCH: Non-empty single-quoted string.
    # REPLACEMENT: Non-empty double-quoted string.
    [
      { kind: :on_tstring_beg,      token: "'" },
      { kind: :on_tstring_content },
      { kind: :on_tstring_end,      token: "'" },
    ],
    proc do |tokens|
      tokens[0][:token] = "\""
      tokens[1][:token] = tokens[1][:token].
        gsub(/\\'/, "'").
        gsub(/"/, "\\\"")
      tokens[-1][:token] = "\""

      tokens
    end
  ]
]

is_match = true
while(is_match)
  idx = 0
  is_match = true
  while(idx < tokens.length)
    RULES.select do |(pattern, action)|
      is_match = true
      last_idx = idx
      pattern.each_with_index do |expectation, offset|
        last_idx = idx + offset

        expectation.keys.each do |key|
          is_match = false unless(expectation[key] == tokens[idx + offset][key])
        end

        break unless(is_match)
      end

      if(is_match)
        prefix = (idx > 0) ? tokens[0..(idx-1)] : []
        suffix = (last_idx < tokens.length) ? tokens[(last_idx+1)..-1] : []
        replacement = action.call(tokens[idx..last_idx])

        tokens = prefix + replacement + suffix
        idx = prefix.length + replacement.length - 1
      end
    end
    idx += 1
  end
end

puts tokens.map { |token| token[:token] }.join
