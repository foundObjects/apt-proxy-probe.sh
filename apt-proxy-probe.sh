#!/usr/bin/env bash
#
# apt-proxy-probe.sh
# https://github.com/foundObjects/apt-proxy-probe.sh

# This is a simple APT proxy detection script for APT that allows you to configure APT
# proxies that may not be available all the time, proxies will be used when available and
# ignored transparently when they're not.

# We may need extra time to resolve proxy hostnames on the first attempt per apt run
# subsequent queries are cached and should return immediately
timeout=5

# plaintext list of configured proxy URLs
proxyfile="/etc/apt/proxies.list"

if [[ -f "$proxyfile" ]]; then
  # Load list of proxies from our proxyfile; probe each until we locate an available proxy, print
  # its URL for APT and immediately exit. If no configured proxies are available print "DIRECT"
  # and APT will connect to the remote directly.
  IFS=$'\n' read -d '' -r -a proxies < "$proxyfile"

  for p in "${proxies[@]}"; do
    # skip comment lines and those containing only whitespace
    [[ "$p" =~ ^([[:space:]]*#|[[:space:]]*$) ]] && continue

    # chop any comments off the end of lines
    p=${p%%\#*}                         # p, minus longest instance of '#*' from the right

    # strip any trailing or leading whitespace to handle indentation or strays at EOL
    # whitespace isn't valid in URL syntax so we can cheat and just wipe out all [[:space:]]
    p=${p//[[:space:]]/}

    # treat any remainder as a URL fragment p
    if [[ "$p" =~ \[.*\] ]]; then
      # then try to extract an ipv6 address
      host=${p%]:*}                     # p, minus shortest instance of ']:*' from the right
      host=${host#*[}                   # also strip shortest instance of '*[' from the left
    else
      # or else hostname/ipv4
      host=${p%:*}                      # p, minus shortest instance of ':*' from the right
    fi
    port=${p##*:}                       # p, minus longest instance of '*:' from the left

    # probe for proxy service with netcat
    if nc -w"$timeout" -z "$host" "$port"; then
      # and print it for APT everything succeeded
      printf "http://%s" "$p"
      exit
    fi
  done
fi

# if any of that failed return DIRECT indicating no proxy is available,
# and APT will get on with its business
printf "DIRECT"
