#!/usr/bin/env python3

import os
import pexpect
import logging
import argparse
import time

def get_args():
    p = argparse.ArgumentParser()
    p.add_argument("-f", nargs='*', help="Files to source before attempting completion")
    p.add_argument("-d", help="Working directory to be in")
    p.add_argument("cmd", help="Command to complete")
    p.add_argument("--debug", action='store_true')
    return p.parse_args()

def main():
    args = get_args()
    fmt="[{levelname} - {funcName}] {message}"
    logging.basicConfig( format=fmt, style='{',
        level=(logging.DEBUG if args.debug else logging.INFO)
    )
    comp = CompletionRunner(init_files=args.f, directory=args.d)
    results = comp.get_completion_candidates(args.cmd, timeout=1)
    print(results)

class CompletionRunner:
    def __init__(self, PS1="@/", directory=None, init_files=None, init_commands=None, logfile=None):
        self.PS1 = PS1
        env = os.environ.copy()
        env['TERM']='dumb'
        self.bash = pexpect.spawn(
            "bash --norc",
            cwd=(os.path.realpath(directory) if directory else os.getcwd()),
            encoding='utf-8',
            env=env,
            dimensions=(24,240),
            logfile=open(logfile,'a') if logfile else None
        )
        self.bash.sendline(f"PS1={self.PS1}")
        self.bash.expect_exact(f"PS1={self.PS1}\r\n{self.PS1}")
        if init_files:
            # To load bash_completion and the completion definitions for
            # the command we want to test.
            for f in init_files:
                self.run_command(f"source {f}")
        if init_commands:
            for c in init_commands:
                self.run_command(c)
        self._setup_readline()

    def __del__(self):
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

    def run_command(self, cmd, nl_after_command=True, nl_before_ps1=False):
        logging.debug(f"cmd='{cmd}'")
        self.bash.sendline(cmd)
        self.bash.expect_exact(cmd + ('\r\n' if nl_after_command else ''))
        self.bash.expect_exact(('\r\n' if nl_before_ps1 else '') + self.PS1)
        logging.debug(f"Found ps1 after command '{cmd}'")
        return self.bash.before

    def expect_single_candidate(self, cmd, expected_completion, timeout=None):
        logging.debug(f"sending '{cmd}\\t'")
        self.bash.send(cmd + '\t')
        self.bash.expect_exact(cmd)
        completion = None
        try:
            self.bash.expect_exact(expected_completion, timeout=timeout)
            completion = self.bash.after
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
        logging.debug(f"result = {result}")
        logging.debug(f"expected - result = {set(expected_completions) - result}")
        logging.debug(f"result - expected = {result - set(expected_completions)}")
        return (result == set(expected_completions))


    def get_completion_candidates(self, cmd, timeout=None):
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
