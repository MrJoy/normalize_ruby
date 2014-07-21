#!/bin/bash
rm result.rb result.out
ruby -W0 test.rb > test.out
ruby -W0 expected.rb > expected.out
if [[ $(($(diff -ub test.out expected.out | wc -l) + 0)) -gt 0 ]]; then
  echo "ERROR: expected.rb is stale, please update it."
  exit 1
fi
cat test.rb | bin/normalize_ruby.rb - > result.rb && ruby -W0 result.rb > result.out
diff -ub expected.rb result.rb ; diff -ub expected.out result.out

