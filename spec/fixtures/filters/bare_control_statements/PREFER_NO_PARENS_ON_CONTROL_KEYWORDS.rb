if foo
end

if foo # meh
end

if foo
end

if foo # foo
end

if foo||bar
end

if foo ||
   bar
end

if foo ||   # meh
   bar   # bleah
end

if foo||bar
end

if foo ||
   bar
end

if ( foo ||
   bar )
end

if ( foo ) ||
   ( bar )
end

if ( foo ) ||
   ( bar )
end

foo if bar

foo if bar     # meh

if(foo rescue nil)
end

if foo ||
   bar
end

                      # Comment
if foo                # Aligned comment
end
