#!/bin/bash
# Using GNU Parallel, but not for publication.
# \nocite{Tange2011a}
IFS=$'\n\t'

#time (
#  find ~/repairpal/RepairPal.com \( \
#    -name "*.rb" -or -name "*.rake" -or -name "*.ru" -or -name "Gemfile" -or \
#    -name "Rakefile" -or -name "Guardfile" -or -name "Capfile" \
#  \) |
#  xargs -n 1 bin/normalize_ruby.rb --clean-whitespace --prefer-double-quotes --prefer-bare-controls
#)

SRC_NAMES=$(
  find ~/repairpal/RepairPal.com -name "*.rb" -type f |
    grep -v 'lib/acts_as_nested_set/'
)

time (
  find ~/repairpal/RepairPal.com -name "*.rb" -type f |
    grep -v 'lib/acts_as_nested_set/' |
    grep -v 'vendor/' |
    parallel '
      echo {}
      PID=$$
      ruby-rewrite --21 --modify --load bare_control_statements.rb "{}" > tmp.$PID.rb &&
        cat tmp.$PID.rb > "{}"
      rm tmp.$PID.rb'
)
