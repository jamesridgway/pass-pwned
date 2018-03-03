#!/usr/bin/env bash
# pass pwned - Password Store Extension (https://www.passwordstore.org/)


pwned_password()
{
	local password sha1 short_sha1 sha1_suffix http_status http_body http_response
	password="$1"
	sha1=$(echo -n "$password" | shasum | awk '{print toupper($1)}')
	short_sha1=${sha1:0:5}
	sha1_suffix=${sha1:5}

	http_response=$(curl -s -w '\nHTTPSTATUS:%{http_code}\n' "${PWNED_BASE_URL}/range/${short_sha1}")
	http_body="$(echo "$http_response" | sed '$d')"
	http_status=$(echo "$http_response" | tail -1 | sed -e 's/.*HTTPSTATUS://')

	if ! [[ "${PWNED_BASE_URL}" =~ ^file:// ]] && [ ! "$http_status" -eq 200 ]; then
	  echo "Error [HTTP status: $http_status]"
	  return 1
	fi

	MATCHES=$(echo "${http_body}" | grep "${sha1_suffix}" | awk -F ':' '{print $2}' | tr -d '[:space:]')
	return 0
}

cmd_pwned_usage()
{
	printf "%b" "
$PROGRAM pwned is a Password Store extension for checking passwords against the pwnedpasswords API.

  Usage:

    $PROGRAM pwned check [pass-name]
        Check the contents of pass-name against pwnedpasswords API. For a
        multiline passfile the first line will be used.

More information may be found in the pass-pwned(1) man page.
"
}

cmd_pwned_check()
{
	local path="${1%/}"
	local passfile="$PREFIX/$path.gpg"
	local contents
	check_sneaky_paths "$path"
	[[ ! -f $passfile ]] && die "Error: $path is not in the password store."

	contents=$($GPG -d "${GPG_OPTS[@]}" "$passfile" | head -n 1)

	pwned_password "${contents}"

	if [ -z "$MATCHES" ]; then
		echo "This password has not appeared in any data breaches!"
	else
		echo "This password has appeared ${MATCHES} times in data breaches."
		exit 2
	fi

}


PWNED_BASE_URL="${PWNED_BASE_URL:-https://api.pwnedpasswords.com}"
case "$1" in
  help|--help|-h)
    shift
    cmd_pwned_usage "$@"
    ;;
  check|--check)
    shift
    cmd_pwned_check "$@"
    ;;
  *)
    cmd_pwned_check "$@" ;;
esac