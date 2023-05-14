# apt-proxy-probe.sh

## about

`apt-proxy-probe` (APP) is a simple tool designed for Debian systems to streamline the use of `apt-cacher-ng` proxy servers. It automatically connects APT to available proxies from a configured list and falls back to a direct connection when none are accessible, ensuring uninterrupted service.

APP is ideal for:

- **Debian laptops:** If you move between two or more networks, each with its own proxy (or none at all) APP ensures you use whichever proxy is currently available.
- **Servers and Containers:** If you wish to use a local `apt-cacher-ng` instance that might not always be available APP will use the proxy when possible and fall back to a direct connection automatically when needed.

With APP there's no need for special handling or reconfiguration of APT if a proxy is unavailable. APP probes each proxy during updates and automatically bypasses any that are unreachable. This eliminates the need to manually set environment variables or adjust `apt.conf.d` files when switching networks.

The key design goal of APP is simplicity. Once installed and configured via `/etc/apt/proxies.list` APT "just works" without requiring any further configuration or attention.

## dependencies
Openbsd netcat (the `netcat-openbsd` package) is required for ipv6 support; ipv4-only support is available with traditional netcat but this is untested. Be aware that while `netcat-openbsd` is the default on Ubuntu 18.04+, Debian releases prior to Bullseye defaulted to `netcat-traditional`.

If you have problems detecting your proxies in a mixed ipv4/ipv6 or ipv6-only environment the very first thing to do is verify that you're running `netcat-openbsd`.

## `/etc/apt/proxy.list` config.
Proxies are entered one per line. Each entry is a host:port URL fragment containing the apt caching proxy's name or IP address followed by `:` and then proxy port.

E.g.:
```
# this is a single proxy configuration with the proxy
# available on the host proxy.lan at port 3142
proxy.lan:3142
```

Lines beginning with `#` or consisting solely of whitespace are ignored. ipv6 URLs must be bracketed per [RFC2732](https://www.ietf.org/rfc/rfc2732.txt). Leading and trailing whitespace are stripped to allow indentation and handle any stray whitespace at the end of a line.

Further examples:
```
# by hostname:
proxy.lan:3142

# by ipv4 address:
192.168.1.10:3142

# by ipv6 address:
[dead:beef::1]:3142

```

Note: If you're unsure about formatting add "http://" (or "https://") to your URL fragment and try connecting to the proxy with curl. If you can't connect your formatting is almost certainly wrong or your proxy is unreachable.

## debugging problems

First run the proxy probe script manually with `bash -x /usr/local/sbin/apt-proxy-probe.sh` and look for any obvious errors.

To debug problems connecting within APT edit `/etc/apt/apt.conf.d/00proxy` and uncomment the following lines then run `sudo apt-get update` and capture the debug output.

```
//Debug::Acquire::http "true";
//Debug::Acquire::https "true";
```

If you think you've found a bug please open an issue on github and attach the output from both `bash -x /usr/local/sbin/apt-proxy-probe.sh` and the full output of APT with http(s) debugging enabled.

## license & contact

MIT Licensed (c) 2020, see [LICENSE](LICENSE)

https://github.com/foundObjects/apt-proxy-probe.sh
