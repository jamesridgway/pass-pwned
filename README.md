# pass-pwned
A [pass](https://www.passwordstore.org/) extension for checking passwords against [pwnedpasswords](https://www.troyhunt.com/ive-just-launched-pwned-passwords-version-2/) API.

This extension supports checking individual passwords or all passwords against the API.

If you're concerned about using the API, you can provide a pssword hash file to use instead via the `-f` or `--file` option.


## Usage
```
pass pwned is a Password Store extension for checking passwords against the pwnedpasswords API.

  Usage:

    pass pwned check [-f <filename>] [pass-name]
        Check the contents of pass-name against pwnedpasswords API. For a
        multiline passfile only the first line will be checked.

        Using the -f or --file flag will use the provided password hash
        file instead of the pwnedpasswords API.

        If you want to check all of your password store entries, don't
        provide a pass-name.

  Options:
    -f, --file    Provide a password hash file to use instead of the API.

More information may be found in the pass-pwned(1) man page.
```

## Installation

### Manual
```
git clone https://github.com/jamesridgway/pass-pwned.git
cd pass-pwned
make install
```
