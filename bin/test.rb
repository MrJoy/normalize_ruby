#!/usr/bin/env ruby

require 'ripper'

fname = ARGV.shift
lexemes = Ripper.
  lex(File.read(fname), fname).
  map { |((line_no, col_no), kind, token)| { line: line_no, col: col_no, kind: kind, token: token } }

RULES=[
  [
    # MATCH: Empty single-quoted string.
    # REPLACEMENT: Empty double-quoted string.
    [
      { kind: :on_tstring_beg,      token: "'" },
      { kind: :on_tstring_end,      token: "'" },
    ],
    "\"\""
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

idx = 0
while(idx < lexemes.length)
  RULES.select do |(pattern, action)|
    is_match = true
    last_idx = idx
    pattern.each_with_index do |expectation, offset|
      last_idx = idx + offset

      expectation.keys.each do |key|
        is_match = false unless(expectation[key] == lexemes[idx + offset][key])
      end

      break unless(is_match)
    end

    if(is_match)
      prefix = (idx > 0) ? lexemes[0..(idx-1)] : []
      suffix = (last_idx < lexemes.length) ? lexemes[(last_idx+1)..-1] : []
      replacement = case action.class.to_s
      when "String"
        [{ :token => action }]
      when "Array"
        action
      when "Proc"
        action.call(lexemes[idx..last_idx])
      end

      lexemes = prefix + replacement + suffix
      idx = -1 # Start over so we can match against post-replacement stream...
    end
  end
  idx += 1
end

tokens = lexemes.map { |lexeme| lexeme[:token] }

File.open(fname, "w") do |fh|
  fh.write tokens.join
end
