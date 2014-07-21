#!/bin/bash

find . -name "*.rb" |
  grep -v -E '^\./spec/fixtures' |
  xargs -I{} -n 1 bin/normalize_ruby.rb \{\} --clean-whitespace --prefer-single-quotes --prefer-bare-controls

