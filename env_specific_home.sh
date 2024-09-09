#!/bin/bash

export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

export PATH=$HOME/.gem/ruby/2.6.0/bin:$PATH
export PATH=/opt/homebrew/share/perl6/site/bin/:$PATH
export PATH=/Users/pcarphin/perl5/bin:${PATH}
PERL5LIB="/Users/pcarphin/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/pcarphin/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/pcarphin/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/pcarphin/perl5"; export PERL_MM_OPT;

# echo "Prepending homebrew path"
export PATH=/opt/homebrew/bin:${PATH}

