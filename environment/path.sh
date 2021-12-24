#!/bin/bash
# PATH=${PATH:+${PATH}:}:$HOME/.local/bin

export PATH=$HOME/.local/bin${PATH:+:${PATH}}
export PATH=$HOME/fs/bin${PATH:+:${PATH}}
export PATH=$HOME/go/bin${PATH:+:${PATH}}
export PATH=/opt/homebrew/bin${PATH:+:${PATH}}
