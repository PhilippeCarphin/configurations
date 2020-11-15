function check_git
    set gv (git --version | cut -d ' ' -f 3)
    set major (cut -d '.' -f 1 <<< $gv)
    set minor=(cut -d '.' -f 2 <<< $gv)
    echo major minor
    if [ (git --version) = "allo" ]
        echo "ALLO"
    else
        echo "Not allo"
    end
end

function git_stoneage_message
    set gv $1
    echo (tput setab 1)(tput setaf 15)"You are using a version of git "(tput setab 3)"("$gv")"(tput setab 1)(tput setaf 15)" from the stone age"(tput sgr 0)
    echo "You can setup links to things in (tput setaf 2)/ssm/net/cmoi/apps/git/...(tput sgr 0) to put in (tput setaf 2)~/.local/bin(tput sgr 0)"
    echo "make sure you do the same for gitk"
end
