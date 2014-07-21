#!/bin/bash
rm result.rb result.out
ruby test.rb > test.out
ruby expected.rb > expected.out
if [[ $(($(diff -ub test.out expected.out | wc -l) + 0)) -gt 0 ]]; then
  echo "ERROR: expected.rb is stale, please update it."
  exit 1
fi
cat test.rb | bin/normalize_ruby.rb - > result.rb && ruby result.rb > result.out
diff -ub expected.rb result.rb ; diff -ub expected.out result.out

