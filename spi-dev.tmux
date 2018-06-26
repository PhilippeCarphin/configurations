#!/bin/tmux

# new-window
split-window -h -d
split-window -t 0 -d

send-keys -t 0 'cd ${SPI_DIR}/LibTkGL/TclGeoEER' enter
send-keys -t 1 'cd ${SPI_DIR}/LibTkGL/TclGeoEER' enter
send-keys -t 2 'cd ${SPI_DIR}/LibTkGL/TclGeoEER' enter


send-keys -t 0 'cd MetObsTest; clear' enter

send-keys -t 1 'question' enter

send-keys -t 2 'cd generic' enter
send-keys -t 2 "vim *" enter enter
send-keys -t 2 ":b tclMetObs_SQLite.c" enter

select-pane -t 2

#===============================================================================
new-window
split-window -h -d
split-window -t 0 -d

send-keys -t 0 'cd ${SPI_DIR}/eer_SPI/tcl/' enter
send-keys -t 1 'cd ${SPI_DIR}/eer_SPI/tcl/' enter
send-keys -t 2 'cd ${SPI_DIR}/eer_SPI/tcl/' enter

send-keys -t 0 'clear ; echo "Bonjour Phil"' enter

send-keys -t 1 'clear ; echo "Bienvenu dans TMUX"' enter

send-keys -t 2 "vimf '*.tcl'" enter enter
send-keys -t 2 ":b Obs.tcl"
send-keys -t 2 tab enter
# send-keys -t 2 ":976" enter "zt"

select-pane -t 2

