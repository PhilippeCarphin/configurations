# Defined in /tmp/afsmpca/fish.0KJcki/p.verify-runner.fish @ line 1
function p.verify-runner
	ssh sgci800@ppp4 'gitlab-ci/bin/gitlab-ci-multi-runner-linux-amd64 verify'
end
