if [ $TERM = 'dumb' ]
    exec bash
end

set -x fish_greeting (date)

# Path to Oh My Fish install.
set -q XDG_DATA_HOME
  and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
  or set -gx OMF_PATH "$HOME/.local/share/omf"
# Load Oh My Fish configuration.
source $OMF_PATH/init.fish

set -x PHIL_CONFIG $HOME/.philconfig
set profile_files ~/.config/fish/conf.d/omf.fish ~/.philconfig/envvars.fish

function my-ip -d "Prints public ip"
    curl ipinfo.io/ip
end

function gitk -d "Adds --all flag and '&' to gitk"
    command gitk --all &
end

function git-gui -d "Adds '&' to git gui"
    command git gui &
end

function profile
    set profile_files ~/.philconfig/config/fish/conf.d/omf.fish ~/.philconfig/envvars.fish
    emacsclient -t $profile_files
    fish
end

function realpath
    if [ -n $argv[1] ]
        set input_path $PWD
    else
        set input_path $argv[1]
    end

    python -c "import os,sys; print(os.path.realpath(sys.argv[1]))" $input_path
end

source $PHIL_CONFIG/envvars.fish
