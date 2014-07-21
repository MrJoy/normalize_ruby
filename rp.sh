#!/bin/bash

time (
  find ~/repairpal/RepairPal.com \( \
    -name "*.rb" -or -name "*.rake" -or -name "*.ru" -or -name "Gemfile" -or \
    -name "Rakefile" -or -name "Guardfile" -or -name "Capfile" \
  \) |
  xargs -n 1 bin/normalize_ruby.rb --clean-whitespace --prefer-double-quotes --prefer-bare-controls
)
