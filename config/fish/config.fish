set -x fish_greeting (date)

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
    exec fish
end

function github
    cd ~/Documents/GitHub
end

function grep
    command grep -n --color $argv
end

function realpath
    if [ -n $argv[1] ]
        set input_path $PWD
    else
        set input_path $argv[1]
    end

    python -c "import os,sys; print(os.path.realpath(sys.argv[1]))" $input_path
end

function serve-pwd
    browser-sync start -s -f . --no-notify --host 0.0.0.0 --port 9000
end
