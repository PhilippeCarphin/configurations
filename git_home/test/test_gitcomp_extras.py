import comptest
import os
import sys
import logging
import subprocess

fmt="[{levelname} - {funcName}] {message}"
logging.basicConfig( format=fmt, style='{',
    level=(logging.DEBUG if 'DEBUG_TESTS' in os.environ else logging.INFO)
)
# git_home
root_dir = os.path.normpath(f"{os.path.dirname(os.path.realpath(__file__))}/../")


if os.uname().sysname == "Darwin":
    bash_completion = "/opt/homebrew/share/bash-completion/bash_completion" \
    if os.uname().sysname == "Darwin" \
    else "/usr/share/bash-completion/bash_completion"

git_completion = os.path.expanduser("~/Repositories/github.com/git/git/contrib/completion/git-completion.bash")

# Ensure existence of empty directories that we can't track with git.
# Normally we would create a file like `.empty` in the directory and track
# that to ensure the directory exists but because we need the directory to
# be really empty for testing, we have to do it this way.
test_repo = f"{root_dir}/test/mock_files/git-repo"
if not os.path.exists(test_repo):
    os.makedirs(test_repo, exist_ok=True)
    subprocess.run(['git', 'init'], cwd=test_repo, check=True)
    # TODO: Completion of relative URLs requires the repo to have a remote named 'origin'
    #       It should be improved use the URL of the default push remote or something
    subprocess.run(['git', 'remote', 'add', 'origin', 'git@github.com:philippecarphin/configurations'], cwd=test_repo, check=True)
    subprocess.run(['git', 'remote', 'add', 'yay', 'git@yay'], cwd=test_repo, check=True)
    subprocess.run(['git', 'remote', 'add', 'boo', 'git@boo'], cwd=test_repo, check=True)
os.makedirs(f"{root_dir}/test/__pycache__", exist_ok=True)

c = comptest.CompletionRunner(
    init_commands=[
        f"source {bash_completion}",
        f"source {git_completion}",
        f"source {root_dir}/git-completion-extras.bash",
        "bind 'set visible-stats off'",
        "bind 'set mark-directories off'",
        "bind 'set echo-control-characters off'",
    ],
    directory=test_repo,
    PS1="@COMPTEST@",
    logfile=f"{root_dir}/test/test_log.txt"
)

A_TEST_FAILED = False
def count_result(test_result, expected_result=True):
    global A_TEST_FAILED
    if test_result == expected_result:
        print("SUCCESS")
    else:
        print("FAIL")
        A_TEST_FAILED = True
        sys.exit(77)
def test_clone():

    count_result(c.expect_single_candidate( "git clone g", "it@"))
    count_result(c.expect_multiple_candidates("git clone git@",
                 ["git@github.com:", "git@gitlab.com:", "git@gitlab.science.gc.ca:"]))
    count_result(c.expect_multiple_candidates("git clone https://",
                 ["https://github.com/", "https://gitlab.com/", "https://gitlab.science.gc.ca/"]))
    count_result(c.expect_multiple_candidates("git clone git@github.com:",
                 ["ECCC-ASTD-MRD/", "itsgifnotjiff/", "philippecarphin/"]))
    count_result(c.expect_multiple_candidates("git clone ../",
                 ["other-dir", "git-repo"]))
    count_result(c.expect_multiple_candidates("git clone ../../",
                 ['mock_files', '__pycache__']))

    count_result(c.expect_multiple_candidates("git remote add ", ["origin", "upstream", "phb", "jp"]))
    count_result(c.expect_single_candidate("git remote add upstream g", "it@"))
    count_result(c.expect_multiple_candidates("git remote add upstream git@",
                 ["git@github.com:", "git@gitlab.com:", "git@gitlab.science.gc.ca:"]))
    count_result(c.expect_multiple_candidates("git remote add upstream https://",
                 ["https://github.com/", "https://gitlab.com/", "https://gitlab.science.gc.ca/"]))
    count_result(c.expect_single_candidate("git remote add upstream ../..", "/"))
    count_result(c.expect_multiple_candidates("git remote add upstream ../",
                 ["other-dir", "git-repo"]))

    count_result(c.expect_single_candidate("git remote add upstream g", "it@"))
    count_result(c.expect_multiple_candidates("git remote add upstream git@",
                 ["git@github.com:", "git@gitlab.com:", "git@gitlab.science.gc.ca:"]))
    count_result(c.expect_multiple_candidates("git remote add upstream https://",
                 ["https://github.com/", "https://gitlab.com/", "https://gitlab.science.gc.ca/"]))

    # TODO: Understand why there is a space after origin and boo or adapt the
    #       tests to ignore spaces in candidates.
    count_result(c.expect_multiple_candidates("git remote set-url ", ['origin ', 'yay', 'boo ']))



test_clone()

sys.exit(A_TEST_FAILED)
