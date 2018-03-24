#!/usr/bin/env bash
# pass pwned - Password Store Extension (https://www.passwordstore.org/)


pwned_password_online()
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

pwned_password_data_file()
{
	if ! [ -x "$(command -v bsearch)" ]; then
		echo "ERROR: bsearch is required for data file option, please install bsearch."
		exit 1
	fi
	local data_file password sha1
	data_file="$1"
	password="$2"
	sha1=$(echo -n "$password" | shasum | awk '{print toupper($1)}')
	MATCHES=$(bsearch "${sha1}" "${data_file}" | awk -F ':' '{print $2}' | tr -d '[:space:]')
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
	opts="$($GETOPT -o f: -l file:, -n "$PROGRAM" -- "$@")"
	eval set -- "$opts"
	while true; do case $1 in
		-f|--file) data_file=$2; shift 2;;
		--) shift; break ;;
	esac done

	if [ -z "$1" ]; then
		local breached_password=0

		IFS=$'\n' read -d '' -r -a pass_names < <( find "$PREFIX" -type f -name "*.gpg" | sed 's/.gpg$//g' | sed "s#${PREFIX}/##g" )

		for pass_name in "${pass_names[@]}"
		do
			if ! check_indivial_password "${pass_name}"; then
				breached_password=1
			fi
		done
		if [ ! "$breached_password" -eq "0" ]; then
			exit 2
		fi
	else
		if ! check_indivial_password "$1"; then
			exit 2
		fi
	fi

	exit 0

}

check_indivial_password()
{
	local path="${1%/}"
	local passfile="$PREFIX/$path.gpg"
	local contents
	check_sneaky_paths "$path"
	[[ ! -f $passfile ]] && die "Error: $path is not in the password store."

	contents=$($GPG -d "${GPG_OPTS[@]}" "$passfile" | head -n 1)

	if [ -z "$data_file" ]; then
		pwned_password_online "${contents}"
	else
		pwned_password_data_file "${data_file}" "${contents}"
	fi

	if [ -z "$MATCHES" ]; then
		echo "The password for '$1' has not appeared in any data breaches."
		return 0
	else
		echo "The password for '$1' has appeared ${MATCHES} times in data breaches!"
		return 2
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