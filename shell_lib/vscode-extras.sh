################################################################################
# Certain things about our environment setup don't jive well with vscode-server
# so we override them for that case.
# - TMPDIR: contains the PID of the process that loaded ordenv. Otherwise:
#   - parent : lauches a child
#   - child : has TMPDIR which contains PID of parent
#   - parent : detaches child and exits, causing r.cleanup_tmpdir to delete
#              TMPDIR
#   - child : has a TMPDIR which does not exist.
# NOTE: The r.cleanup_tmpdir that gets done is because we can't trust all
# applications to cleanup their temporary files.  However VSCode is a legit
# application and it can be trusted to do so.  Therefore for VSCode, we expect
# it to do cleanup.  For integrated shells forked by VSCode, the profile will
# set the tmpdir to something else and therefore the `r.cleanup_tmpdir` ran
# when exiting those shells will not erase the TMPDIR set here.
################################################################################
# Dump environment to file at very beginning to see what the env looks
# like when vscode server logs in.
#
# env -0 | sort -z | tr '\0' '\n' > ~/env_$(date +%Y-%m-%d_%H.%M.%S)
#
if [[ -n $VSCODE_AGENT_FOLDER ]] ; then
    export GO111MODULES=off
    export TMPDIR=/tmp/$USER/vscode-server
    mkdir -p ${TMPDIR}
fi

# At work, the sshd config is has a slight problem.  The expected behavior
# is that sshd creates /run/user/$(id -u) and sets XDG_RUNTIME_DIR to that
# value.  The observed behavior is that it sets XDG_RUNTIME_DIR but does
# not always create the directory.  Only sshd can create this directory, the
# user cannot.  To mitigate this, I set it to something else.
export XDG_RUNTIME_DIR=/tmp/$USER/xdg_runtime_dir
mkdir -p ${XDG_RUNTIME_DIR}
chmod 0700 ${XDG_RUNTIME_DIR}
