module Dummy
  $gvar = 'GVAR'
  @ivar = 'IVAR'
  @@cvar = 'CCVAR'
  puts ""
  puts ""
  puts "foo"
  puts "foo's bar"
  puts "foo \"bar\" baz"
  puts "foo \#{hash and braces} bar"
  puts "foo ## hash escape"
  puts "foo \#$gvar bar"
  puts "foo \#@ivar bar"
  puts "foo \#@@cvar bar"
  puts "adjacent escaping \\\n maybe"
  puts "foo\nbar"
  puts "foo
  bar"
  puts 'foo
  bar'
  puts "foo
"
  puts 'foo
'
  puts "foo #{1 + 1} bar"
  puts "foo #$gvar bar"
  puts "foo #@ivar bar"
  puts "foo #@@cvar bar"
  puts "foo\070bar"
  puts "foo\x40bar"
  puts '\n'
  puts "\n"
  puts "\r"
  puts "\f"
  puts "\b"
  puts "\a"
  puts "\e"
  puts "\s"
  puts "\cm"
  puts "\C-m"
  puts "\M-m"
  puts "\M-\C-m"
  puts "\q"
  puts '\q'
  puts "\'"
  puts "\""
  puts "\\"
  puts '\\'
  puts '\\1'
  puts '\\\\'
  puts 'jQuery(\'#dialog_errors\').html'
end
