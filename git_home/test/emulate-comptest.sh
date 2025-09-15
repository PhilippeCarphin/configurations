unset PROMPT_COMMAND

bind "set page-completions off"
        # Don't query when there are lots of completions
bind "set completion-query-items -1"
        # Print each completion on its own line
bind "set completion-display-width 0"
        # Press TAB once to see all completions
bind "set show-all-if-ambiguous"
        # Prevent output from getting polluted with Bell (\a) or ANSI color codes
bind "set bell-style none"
bind "set colored-completion-prefix off"
bind "set colored-stats off"
PS1="@/"

