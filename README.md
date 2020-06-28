# apt-proxy-probe.sh
apt-proxy-probe.sh is a simple proxy probe script for APT, given a plaintext list of proxy service URLs
(`/etc/apt/proxies.list`) the script probes for available proxies at APT runtime and uses the first found. If no
configured proxy is available the probe script allows APT to transparently fall back to a direct connection to the
package repository.

This is useful if you're using a machine (laptop) that frequently switches networks or you want systems to connect
reliably when a proxy service may not be 100% available. This also allows seamless failover to backup proxies in case
the primary is offline.

### dependencies:
Openbsd netcat required for ipv6 support; the script should function with traditional netcat on ipv4 only networks but
this is untested. Be aware: `netcat-openbsd` is the default on Ubuntu 18.04+(?), Debian defaults to `netcat-traditional`
as of Buster. If you have problems finding your proxies in a mixed ipv4/6 environment switch to `netcat-openbsd` first.

### proxy list format
One entry per line, each is a host:port URL fragment of an apt caching proxy URL. Lines beginning with # or consisting
solely of whitespace are ignored. ipv6 URLs must be bracketed per [RFC2732](https://www.ietf.org/rfc/rfc2732.txt)

Examples:
```
# by hostname:
proxy.lan:3142

# by ipv4 address:
192.168.1.10:3142

# by ipv6 address:
[dead:beef::1]:3142
```

Note: If you can't prepend "http://" to the host/port URL fragment and connect to the proxy with curl your formatting is
probably wrong.

### debugging problems

First run the proxy probe script manually with `bash -x /usr/local/sbin/apt-proxy-probe.sh` and look for errors.

To debug problems connecting with APT edit `/etc/apt/apt.conf.d/00proxy` and uncomment the following lines then run
`sudo apt-get update` and check the debug output.
```
//Debug::Acquire::http "true";
//Debug::Acquire::https "true";
```

If you think you've found a bug please upload both the `bash -x` script run and the full output of APT with http(s)
debugging enabled as a gist and link them in your issue.
