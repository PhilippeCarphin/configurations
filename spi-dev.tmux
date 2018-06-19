#!/bin/tmux

# new-window
split-window -h -d
split-window -t 0 -d

send-keys -t 0 'cd ${SPI_DIR}/LibTkGL/TclGeoEER' enter
send-keys -t 1 'cd ${SPI_DIR}/LibTkGL/TclGeoEER' enter
send-keys -t 2 'cd ${SPI_DIR}/LibTkGL/TclGeoEER' enter


send-keys -t 0 'cd MetObsTest; clear' enter

send-keys -t 1 'question' enter

send-keys -t 2 'cd generic ; clear' enter
send-keys -t 2 "vim *" enter
send-keys -t 2 ":b tclMetObs_SQLite.c" enter

select-pane -t 2

#===============================================================================
new-window
split-window -h -d
split-window -t 0 -d

send-keys -t 0 'cd ${SPI_DIR}/eer_SPI/tcl/' enter
send-keys -t 1 'cd ${SPI_DIR}/eer_SPI/tcl/' enter
send-keys -t 2 'cd ${SPI_DIR}/eer_SPI/tcl/' enter

send-keys -t 0 'echo "Bonjour Phil"' enter

send-keys -t 1 'echo "Bienvenu dans TMUX"' enter

send-keys -t 2 "vimf '*.tcl'" enter enter
send-keys -t 2 ":b Obs.tcl" tab enter

select-pane -t 2

rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
rename-window -t 1 "LibTkGL"
rename-window -t 2 "eer_SPI"
