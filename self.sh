#!/bin/bash

# find . -name "*.rb" |
#   grep -v -E '^\./spec/fixtures' |
#   xargs -I{} -n 1 bin/normalize_ruby.rb \{\} --clean-whitespace --prefer-single-quotes --prefer-bare-controls

time (
  find . -name "*.rb" -type f |
    grep -v -E '^\./spec/fixtures' |
    while read FNAME; do
      ruby-rewrite --21 --modify --load bare_control_statements.rb "$FNAME" > tmp.rb &&
        cat tmp.rb > "$FNAME"
    done
)
