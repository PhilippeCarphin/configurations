

   export SEQ_TRACE_LEVEL=1:TL_FULL_TRACE
   case $- in
      *i*)
         export domain="/users/dor/afsi/phc/Testing/testdomain"
         export CMCLNG=english
         echo "   Loading CMC commands "
         . ssmuse-sh -d cmoi/apps/git/20150526
         . ssmuse-sh -d cmoi/apps/git-procedures/20150622
         if [ `hostname` == artanis ] ; then
            echo "      ssm'ing maestro 1.5 development version"
            maestro=$domain
         else
            echo "      ssm'ing maestro 1.5.0-rc7"
            maestro=/ssm/net/isst/maestro/1.5.0-rc7
         fi
         . ssmuse-sh -d $maestro
         export SEQ_MAESTRO_SHORTCUT=". ssmuse-sh -d $maestro"
         alias runxp=/users/dor/afsi/dor/ovbin/i686/runxp
         alias xflow_overviewSuites="xflow_overview -suites ~afsiops/xflow.suites.xml;echo allo"
         alias runxp_phil='/usr/bin/rdesktop -a 16 -r sound:local -g 1500x1100 eccmcwts3'
         alias cmc_origin='cd /home/ordenv/GIT-DEPOTS/impl/isst'
         alias dor_origin='cd /home/ops/afsi/dor/tmp/maestro_depot'
         # Example error line: mtest_main.c:479:4 error expected ';' before 'if' ...
         # -> anything, then some digits, then a ':', some digits, a ':', then a space, then 'error'
         alias emake="make 2>&1 | grep '.*[0-9]\+:[0-9]\+: error' --color=always --after-context=4"
         alias wmake='make 2>&1 | grep '.*warning' --color=always --after-context=4'
         alias nmake='make 2>&1 | grep '.*note' --color=always --after-context=4'


         if [ `hostname` != artanis ] ; then
            alias mcompile='export SEQ_EXP_HOME=$HOME/Documents/Experiences/compilation && maestro -d 20160119000000 -n /compile -s submit -f continue'
            alias xcompile='export SEQ_EXP_HOME=$HOME/Documents/Experiences/compilation && xflow'
         fi

         . ssmuse-sh -d $maestro
         export SEQ_MAESTRO_SHORTCUT=". ssmuse-sh -d $maestro"
         if [ `which git` = /usr/bin/git ] ; then
            # To protect against using a bad version of git.
            alias git="echo bad version of git"
         fi
         ;;
      *)
         ;;
   esac
ssmdev(){
   maestro=$domain
   . ssmuse-sh -d $maestro
   export SEQ_MAESTRO_SHORTCUT=". ssmuse-sh -d $maestro"
}
