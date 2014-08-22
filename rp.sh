#!/bin/bash
IFS=$'\n\t'

time (
  bin/normalize_ruby $(
    find ~/repairpal/RepairPal.com -name "*.rb" -type f |
      grep -v 'lib/acts_as_nested_set/' |
      grep -v 'script/minify/' |
      grep -v 'vendor/'
  )
)
