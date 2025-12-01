import comptest
import sys
import os

bash_comp = comptest.find_bash_completion()
if not bash_comp:
    print("No bash_completion")
    sys.exit(1)

c = comptest.CompletionRunner(
        init_files=[bash_comp, os.path.expanduser("~/.git-completion.bash"), "git-completion-extras.bash"],
        logfile='comptest_log.txt'
        )

if c.expect_multiple_candidates('git remote add ', {'github', 'gitlab', 'jp', 'phb', 'upstream', 'origin'}):
    print("test passed")
else:
    print("test failed")

if c.expect_multiple_candidates('git remote add origin ', {'https://', 'git@'}):
    print("test passed")
else:
    print("test failed")

if c.expect_single_candidate('git remote add origin g', 'it@'):
    print("test passed")
else:
    print("test failed")

if c.expect_multiple_candidates('git remote add origin git@', {'git@gitlab.com:', 'git@github.com:', 'git@gitlab.science.gc.ca:'}):
    print("test passed")
else:
    print("test failed")

if c.expect_multiple_candidates('git remote add origin ./', {'git@gitlab.com:', 'git@github.com:', 'git@gitlab.science.gc.ca:'}):
    print("test passed")
else:
    print("test failed")

