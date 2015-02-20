    # include .bashrc if it exists
    if [ -f "$HOME/.bash_profile" ]; then
	source $HOME/.bash_profile
    fi
PS1='\[\e[0;32m\][\u@\h \W] \$ \[\e[0m\]'

alias INF2705='cd ~/Documents/INF2705-Infographie/tp3-orbite/inf2705-base'
alias subl="~/bin/sublime_text"

alias INF1995='firefox http://www.groupes.polymtl.ca/inf1995/tp/'
alias docAtmel='gvfs-open ~/Documents/docAtmel.pdf'
# Put the PDF of the Atmel documentation in the documents folder.

alias docAVRLibC='firefox http://www.nongnu.org/avr-libc/user-manual/index.html'
alias chrome='google-chrome'
alias sublime='sublime-text'
alias facebook='chromium-browser www.facebook.com'
alias INF1995='chromium-browser http://www.groupes.polymtl.ca/inf1995/tp/'
alias hotmail='chromium-browser www.hotmail.com'
alias ssh-school='ssh l4712-05.info.polymtl.ca -l phcarb'
