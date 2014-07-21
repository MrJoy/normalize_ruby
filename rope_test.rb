#!/usr/bin/env ruby
load './lib/normalize/concatenated_array.rb'
x = [:a, :b, :c]
y = [:d, :e]
w = x + y
z = Normalize::ConcatenatedArray.new(x, y)

# puts z[4..4].inspect
# puts z[4..5].inspect
# puts z[5..5].inspect

((-w.length+1)..(w.length+1)).each do |a|
  ((-w.length+1)..(w.length+1)).each do |b|
    zz = z[a..b]
    puts "FAILED #{a}..#{b}: #{zz} vs. #{w[a..b]}" unless zz == w[a..b]
  end
end

puts ([
  z.length == w.length,
  [z[0], z[1], z[2], z[3], z[4]] == [w[0], w[1], w[2], w[3], w[4]],
  [z[0..1], z[1..3], z[2..4]] == [w[0..1], w[1..3], w[2..4]],
  z[-1] == w[-1],
  z[-2] == w[-2],
  z[2..-2] == w[2..-2],
  z[1..-2] == w[1..-2],
  z[2..-1] == w[2..-1],
  z[1..-1] == w[1..-1],
  z[0..-1] == w[0..-1],
].reject { |res| res }.length == 0)
