#!/usr/bin/env bash
# shellcheck disable=SC2016
set -e

export test_description="Testing pass pwned check."

source ./setup

test_cleanup
test_export "check"

test_expect_success 'Test "check" fails for unknown passfile' '
	pass init $KEY1 &&
	! pass pwned check unknown-pass'

test_expect_success 'Test "check" command finds bad password (error message)' '
	pass init $KEY1 &&
	echo -n "P@ssw0rd" | pass insert -e cred1 &&
	[ "$(pass pwned check cred1)" = "The password for '"'"'cred1'"'"' has appeared 47205 times in data breaches!" ]'

test_expect_success 'Test "check" command finds bad password (exit code)' '
	pass init $KEY1 &&
	echo -n "P@ssw0rd" | pass insert -e cred1 &&
	! pass pwned check cred1'


test_expect_success 'Test "check" command determines password (message)' '
	pass init $KEY1 &&
	echo -n "5uP3r$3cUr3/" | pass insert -e cred2 &&
	[ "$(pass pwned check cred2)" = "The password for '"'"'cred2'"'"' has not appeared in any data breaches." ]'

test_expect_success 'Test "check" command determines good password (exit code)' '
	pass init $KEY1 &&
	echo -n "5uP3r$3cUr3/" | pass insert -e cred2 &&
	pass pwned check cred2'


test_expect_success 'Test "check" command ignores second line and fails on the bad password' '
	pass init $KEY1 &&
	echo -e "P@ssw0rd\nSecond line ignored" | pass insert -e cred1 &&
	[ "$(pass pwned check cred1)" = "The password for '"'"'cred1'"'"' has appeared 47205 times in data breaches!" ]'
	

test_done