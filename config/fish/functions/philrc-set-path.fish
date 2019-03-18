# Defined in /tmp/afsmpca/fish.cE5h9q/philrc-set-path.fish @ line 2
function philrc-set-path
	set -l option $argv[1]
   switch $option
      case all
         set -x NEW_PATH (string split ':' $PHILRC_MY_PATH:$PHILRC_SYSTEM_PATH)
      case phil
         set -x NEW_PATH (string split ':' $PHILRC_MY_PATH)
      case system
         set -x NEW_PATH (string split ':' $PHILRC_SYSTEM_PATH)
      case '*'
         echo Unknown option : $option
         return 1
   end
   set -x PATH $NEW_PATH
end
