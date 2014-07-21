#!/bin/bash
rm result.rb result.out
cat test.rb | bin/normalize_ruby.rb > result.rb && ruby result.rb > result.out
diff -ub expected.rb result.rb ; diff -ub expected.out result.out

