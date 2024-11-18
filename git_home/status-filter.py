#!/usr/bin/env -S python3 -u

#
# Colorize git status output to
# - Make submodule summary easier to understand
#   - Missing commits compared to the registered commit in red
#   - New commits compared to the registered commit in green

d = {
        "Submodules changed": "4;36",  # Beginning of submodule section
        "*": "1;37",                   # Header of individual submodule summary
        "  <": "31",                   # Missing commits in submodule
        "  >": "32",                   # Missing commits in submodule
        "Untracked": "1;31"
}

import sys

# Print all lines until we get to submodules
for l in sys.stdin:
    for start, color in d.items():
        if l.startswith(start):
            print(f"\033[{color}m{l}\033[0m", end='')
            break
    else:
        print(l, end='')

