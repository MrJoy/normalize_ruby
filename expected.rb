$gvar = 'GVAR'
@ivar = 'IVAR'
@@cvar = 'CCVAR'
puts ''
puts 'foo'
puts "foo's bar"
puts 'foo "bar" baz'
puts 'foo #{hash and braces} bar'
puts 'foo ## hash escape'
puts 'foo #$gvar bar'
puts 'foo #@ivar bar'
puts 'foo #@@cvar bar'
puts "adjacent escaping \\\n maybe"
puts "foo\nbar"
puts "foo
bar"
puts "foo #{1 + 1} bar"
puts "foo #$gvar bar"
puts "foo #@ivar bar"
puts "foo #@@cvar bar"
