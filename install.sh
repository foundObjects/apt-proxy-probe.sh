#!/bin/bash
set -e

cleanupold="true"

_main() {
  case "$1" in
    "--uninstall")
      # uninstall, requires root
      assert_root
      _uninstall
      ;;
    "--install" | "")
      # install, requires root
      assert_root
      _install "$@"
      ;;
    *)
      # unknown flags, print usage and exit
      _usage
      ;;
  esac
  exit 0
}

rmcmd="rm -f /etc/apt/apt.conf.d/00proxy /etc/apt/proxies.list /usr/local/sbin/apt-proxy-probe.sh"

_install() {
  if [[ -n "$cleanupold" ]] &&
    { [ -f /usr/local/bin/apt-proxy-detect.sh ] || [ -f /usr/local/sbin/apt-proxy-detect.sh ]; }; then
    echo -n "Removing stale proxy detect script ..."
    rm -f /usr/local/bin/apt-proxy-detect.sh /usr/local/sbin/apt-proxy-detect.sh &&
    echo " OK"
  fi
  echo -n "Installing APT proxy-probe ..."
  trap "$rmcmd; echo 'Failed :('" EXIT
  install -o root -m 0644 00proxy /etc/apt/apt.conf.d/00proxy
  install -o root -m 0644 proxies.list /etc/apt/proxies.list
  install -o root -m 0755 apt-proxy-probe.sh /usr/local/sbin/apt-proxy-probe.sh
  trap - EXIT
  echo " Success!"
  echo
  echo "Installation complete, don't forget to edit /etc/apt/proxies.list to include your proxies."
}

_uninstall() {
  echo "Removing APT proxy-probe ..."
  echo
  trap "Failed :(" EXIT
  $rmcmd
  trap - EXIT
  echo "Success! APT proxy-probe removed"
}

assert_root() { [ "$(id -u)" -eq '0' ] || { echo "This action requires root." && exit 1; }; }
_usage() { echo "Usage: $(basename "$0") (--install|--uninstall)"; }

_main "$@"
