module Normalize
  # TODO: Rule for "if" \s* "(" \s* (.+) \s* ")" => "if \1"
  # TODO: Rule for "%q" DELIM ... DELIM => "%q(" ... ")"
  DOUBLE_QUOTED_STRING_LITERAL=[
    { kind: :on_tstring_beg, token: "\"" },
    { kind: :on_tstring_end, token: "\"" },
  ]

  RULES=[
    [
      # MATCH: Empty single-quoted string.
      # REPLACEMENT: Empty double-quoted string.
      [
        { kind: :on_tstring_beg,      token: "'" },
        { kind: :on_tstring_end,      token: "'" },
      ],
      proc do |tokens|
        DOUBLE_QUOTED_STRING_LITERAL
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
          gsub(/\\/, "\\"*3).
          gsub(/"/, '\"').
          gsub(/#\{/, "\\\#{")
        tokens[-1][:token] = "\""

        tokens
      end
    ],
  ]
end
