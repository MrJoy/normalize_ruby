# Notation    Character represented
# \n          Newline (0x0a)
# \r          Carriage return (0x0d)
# \f          Formfeed (0x0c)
# \b          Backspace (0x08)
# \a          Bell (0x07)
# \e          Escape (0x1b)
# \s          Space (0x20)
# \nnn        Octal notation (n being 0-7)
# \xnn        Hexadecimal notation (n being 0-9, a-f, or A-F)
# \cx, \C-x   Control-x
# \M-x        Meta-x (c | 0x80)
# \M-\C-x     Meta-Control-x
# \x          Character x



"\n"       # => ?
"\r"       # => ?
"\f"       # => ?
"\b"       # => ?
"\a"       # => ?
"\e"       # => ?
"\s"       # =>
"\070"     # => 8
"\x40"     # => @
"\cx"      # => ?
"\C-x"     # => ?
"\M-x"     # => ?
"\M-\C-x"  # => ?
"\q"       # => q
"\'"       # => '
"\""       # => "
"\\"       # => \

'\n'       # => \n
'\r'       # => \r
'\f'       # => \f
'\b'       # => \b
'\a'       # => \a
'\e'       # => \e
'\s'       # => \s
'\070'     # => \070
'\x40'     # => \x40
'\cx'      # => \cx
'\C-x'     # => \C-x
'\M-x'     # => \M-x
'\M-\C-x'  # => \M-\C-x
'\q'       # => \q
'\''       # => '
'\"'       # => \"
'\\'       # => \



