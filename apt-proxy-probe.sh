#!/bin/bash

# we may need extra time to resolve proxy hostnames on the first attempt per apt run
# subsequent queries are cached and should return immediately
timeout=5

# plaintext list of possible proxy URLs
proxyfile="/etc/apt/proxies.list"

# Load list of proxies from our proxyfile; probe each until we locate an available proxy, print
# its URL and immediately exit. If no configured proxies are available print "DIRECT" and APT
# will bypass proxying.

if [[ -f "$proxyfile" ]]; then
  IFS=$'\n' read -d '' -r -a proxies < "$proxyfile"

  for p in "${proxies[@]}"; do
    # skip comment lines and those containing only whitespace
    [[ "$p" =~ ^([[:space:]]*#|[[:space:]]*$) ]] && continue

    # strip whitespace to handle indentation and extraneous trailing whitespace
    # whitespace isn't valid URL syntax so squashing all [[:space:]] is fine here
    p=${p//[[:space:]]/}

    # extract hostname/ip and port
    if [[ "$p" =~ \[.*\] ]]; then
      # extract ipv6 address
      host=${p%]:*}                     # p, minus shortest instance of ']:*' from the right
      host=${host#*[}                   # also strip shortest instance of '*[' from the left
    else
      # extract hostname/ipv4 address
      host=${p%:*}                      # p, minus shortest instance of ':*' from the right
    fi
    port=${p##*:}                       # p, minus longest instance of '*:' from the left

    # probe proxy service
    if nc -w"$timeout" -z "$host" "$port"; then
      printf "http://%s" "$p"
      exit
    fi
  done
fi

# return DIRECT if no proxy is available, APT will bypass proxying
printf "DIRECT"
