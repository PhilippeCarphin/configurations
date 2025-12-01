#!/usr/bin/env python3

import sys
import os
import pexpect
import logging
import argparse
import time

# NOTE: I learned how pexpect works and how to use it from a mix of experimentation
# and looking at the code of 'test/t/conftest.py' from the the bash-completion
# repository https://github.com/scop/bash-completion.  Credit where credit is
# due, here are the most important things I learned from that repo:
# - How to change completion settings to work best with pexpect which is the
#   _setup_readline() function here and is 'test/config/inputrc' in bash-completion
# - The right sequence of sending and expecting to get just the output that I
#   want.  However, it is more useful to set a log file in pexpect.spawn() and
#   to 'tail -f' that log file in a separate shell.  Both are useful, I would
#   never have known that I needed to expect '\r's if I was just looking at the
#   log file, but the log file is necessary otherwise I wouldn't have understood
#   what I was doing.
# - Getting the exit codes of commands.  If I had wanted to, I wouldn't have
#   needed their help to do it, but they gave me the idea to want to.
# - Setting wide dimensions.
# I didn't copy them either so it's normal that my thing is different but here
# are some differences that are good to know about
# - They sset a lot of things to ensure that completion picks up the stuff from
#   the bash-completion repo itself rather than what's on the system.  I want
#   to be as close to the system as possible so I don't do that.
# Some questions that I have about how bash-completion does things:
# - They use '@/' as PS1.  I'm not sure why they don't have a more crazy PS1
#   but I guess it never ever occurs naturally.
# - They also define a MAGIC_MARK (and MAGIC_MARK2).  It's used in the function
#   assert_complete.  It looks like when they send most commands, they do
#   bash.sendline(cmd), bash.expect_exact(cmd [+/r/n]), bash.expect_exact(PS1)
#   then the same thing with cmd='echo $?' to get the exit code, but when it
#   comes time to test the actual completion, if the completion produces a
#   single result, BASH won't print another PS1, so what they do is
#   - bash.send(cmd + '\t')  this prints either one completion or many (we don't
#     know which one.
#   - bash.send(MAGIC_MARK) so now we either have
#   /@ <CMD-TO-TEST><REST-OF-SINGLE-COMPLETION><MAGIC_MARK>
#   so if we expect '/@ <CMD-TO-TEST>', then we expect <MAGIC_MARK> then
#   bash.before will be exactly <REST-OF-SINGLE-COMPLETION>.

def get_args():
    p = argparse.ArgumentParser()
    p.add_argument("--init-files", "-f", metavar='FILE', nargs='*', default=[], help="Files to source before attempting completion")
    p.add_argument("--bash-command", help="Bash command (default 'bash --norc')")
    p.add_argument("-d", metavar='DIRECTORY', help="Working directory to be in")
    p.add_argument("cmd", metavar='CMD', help="Command to complete")
    p.add_argument("--debug", action='store_true')
    p.add_argument("--load-bash-completion", "-l", action='store_true', help="Load BASH completion from likely directories")
    p.add_argument("--log-file", help="Log file")
    p.add_argument("--xtrace-log", help="Log file for xtrace output", default=os.path.expanduser("~/.log.txt"))
    p.add_argument("-x", action="store_true", help="Activate xtrace (set -x)")
    p.add_argument("--verbose-ps4", action='store_true', help="Set verbose PS4.  Only useful if -x option is used")
    return p.parse_args()

def find_bash_completion():
    candidates = [
        '/opt/homebrew/share/bash-completion/bash_completion',
        '/usr/local/share/bash-completion/bash_completion',
        '/usr/share/bash-completion/bash_completion'
    ]
    for f in candidates:
        if os.path.exists(f):
            return f

def main():
    args = get_args()
    init_files=[]
    init_commands=[]
    if args.load_bash_completion:
        bash_comp = find_bash_completion()
        if bash_comp:
            init_files.append(bash_comp)
        else:
            print(f"ERROR: Loading bash completion requested but it was not found")
            return 1

    logging.basicConfig(
        format="[{levelname} - {funcName}] {message}",
        style='{',
        level=(logging.DEBUG if args.debug else logging.INFO)
    )

    comp = CompletionRunner(
            bash_command=args.bash_command,
            PS4=('+ ' if not args.verbose_ps4 else
                 '+ \033[35m${BASH_SOURCE[0]:-}\033[36m:\033[1;37m${FUNCNAME:-}\033[22;36m:\033[32m${LINENO:-x}\033[36m:\033[0m '),
            init_files=args.init_files,
            init_commands=init_commands,
            directory=args.d,
            logfile=args.log_file,
            xtrace=args.x,
            xtrace_log=args.xtrace_log
    )

    results = comp.get_completion_candidates(args.cmd, timeout=1)

    comp.close()
    print('\n'.join(sorted(results)))

class CompletionRunner:
    def __init__(self, PS1="@/", PS4='+ ', xtrace=False, xtrace_log=None, directory=None, init_files=None, init_commands=None, logfile=None, bash_command=None):
        self.PS1 = PS1
        self.PS4 = PS4
        self.bash_command = bash_command if bash_command else "bash --norc"
        env = os.environ.copy()
        # env['TERM']='dumb'
        env['PS1'] = self.PS1
        env['PS4'] = self.PS4

        self.bash = pexpect.spawn(
            self.bash_command,
            cwd=(os.path.realpath(directory) if directory else os.getcwd()),
            encoding='utf-8',
            env=env,
            dimensions=(24,240),
            logfile=open(logfile,'a') if logfile else None
        )

        # If we're being loaded with a different command, then loading the
        # profile may change PS1 or set a PROMPT_COMMAND and everything we
        # do is based on knowing what PS1 is so we can use it as a delimiter.
        if bash_command is not None:
            self.bash.sendline(f"unset PROMPT_COMMAND")
            self.bash.sendline(f"PS1={self.PS1}")
            self.bash.expect_exact(f"PS1={self.PS1}\r\n{self.PS1}")

        if xtrace:
            if xtrace_log is None:
                xtrace_log = "xtrace_log.txt"
            init_commands.append(f"exec {{BASH_XTRACEFD}}>>{xtrace_log}")
            init_commands.append("set -x")

        if init_files:
            # To load bash_completion and the completion definitions for
            # the command we want to test.
            for f in init_files:
                res, ok = self.run_command(f"source {f}", check=True)
                if not ok:
                    raise RuntimeError(f"sourcing '{f}' failed")

        if init_commands:
            for c in init_commands:
                res, ok = self.run_command(c, check=True)
                if not ok:
                    raise RuntimeError(f"sourcing '{f}' failed")

        self._setup_readline()

    def close(self):
        # When running this with a command that only produces one
        # candidate, this produces an exception (which is extra bad when it
        # happens inside a '__del__' method.  Why does this only happen when
        # the command produces only one candidate?
        self.bash.send("exit")

    def _setup_readline(self):
        # Pagin could prevent us from getting a PS1 after hitting TAB
        self.run_command('bind "set page-completions off"')
        # Don't query when there are lots of completions
        self.run_command('bind "set completion-query-items -1"')
        # Print each completion on its own line
        self.run_command('bind "set completion-display-width 0"')
        # Press TAB once to see all completions
        self.run_command('bind "set show-all-if-ambiguous"')
        # Prevent output from getting polluted with Bell (\a) or ANSI color codes
        self.run_command('bind "set bell-style none"')
        self.run_command('bind "set colored-completion-prefix off"')
        self.run_command('bind "set colored-stats off"')

    def run_command(self, cmd, nl_after_command=True, nl_before_ps1=False, check=False):
        logging.debug(f"cmd='{cmd}'")
        self.bash.sendline(cmd)
        self.bash.expect_exact(cmd + ('\r\n' if nl_after_command else ''))
        self.bash.expect_exact(('\r\n' if nl_before_ps1 else '') + self.PS1)
        logging.debug(f"Found ps1 after command '{cmd}'")
        result = self.bash.before
        if not check:
            return result
        else:
            echo = 'echo $?'
            self.bash.sendline(echo)
            self.bash.expect_exact(echo + ('\r\n' if nl_after_command else ''))
            self.bash.expect_exact(('\r\n' if nl_before_ps1 else '') + self.PS1)
            exit_code=int(self.bash.before.strip())
            return result, (exit_code == 0)

    def expect_single_candidate(self, cmd, expected_completion, timeout=None):
        logging.debug(f"sending '{cmd}\\t'")
        self.bash.send(cmd + '\t')
        self.bash.expect_exact(cmd)
        completion = None
        try:
            self.bash.expect_exact(expected_completion, timeout=timeout)
            completion = self.bash.after
            logging.debug(f"expect_exact did not time out after = '{self.bash.after}'")
        except pexpect.exceptions.TIMEOUT as t:
            logging.debug(f"Timeout reached")
            self.bash.sendintr()
            self.bash.expect_exact(self.PS1)
            return False
        logging.debug(f"before = '{self.bash.before}'")
        if '\n' in self.bash.before:
            logging.warning(f"newline in buffer between command and expected completion indicates more than one candidate either this indicates a failed test or that the test itself should be done with expect_multiple_candidates()")
            self.bash.sendintr()
            self.bash.expect_exact(self.PS1)
            return False
        self.bash.sendintr()
        self.bash.expect_exact(self.PS1)
        logging.debug(f"expected_completion='{expected_completion}'")
        logging.debug(f"completion='{completion}'")
        return expected_completion == completion

    def expect_multiple_candidates(self, cmd, expected_completions, timeout=None):
        result = self.get_completion_candidates(cmd, timeout)
        logging.debug(f"expected - result = {set(expected_completions) - result}")
        return (result == set(expected_completions))

    def get_completion_candidates(self, cmd, timeout=1):
        # NOTE: bash-completion does something with 'MAGIC_MARK' which seems
        # to be some token that is super unlikely to arise in the ouput of
        # a command.
        logging.debug(f"Getting candidates for command {cmd}")
        logging.debug(f"sending '{cmd}\\t'")
        self.bash.send(cmd + "\t")
        logging.debug(f"expect exact: '{cmd}'")
        self.bash.expect_exact(cmd)
        try:
            self.bash.expect_exact(self.PS1, timeout=timeout)
        except pexpect.exceptions.TIMEOUT as t:
            logging.debug(f"Timeout reached")
        result = set(self.bash.before.strip().splitlines())
        self.bash.sendintr()
        self.bash.expect_exact(self.PS1)
        return result

if __name__ == "__main__":
    main()
