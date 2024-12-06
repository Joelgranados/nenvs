#!/usr/bin/env bash

BASENAME="$(basename "${BASH_SOURCE[0]}")"
BASEDIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

USAGE="Usage: ${BASENAME} ARGS [OPTIONS]

starts/stops vdi vm with virsh command

Args: -n <vdi_name>
  -n, --vdi <vdi_name>  Name of the VDI VM.

Options:
  -c, --connect <URI>   connect URI. Passed along to virsh and
                        virt-manager. Defaults to qemu:///system
  -a, --action          [start|stop] defaults to "start"
  -h, --help            Display this help
"

_usage() {
    if [[ $2 -ne 0 ]]; then
        echo "$1" >&2
        exit "$2"
    fi
    echo "$1"
    exit 0
}

get_vdi_opts()
{
  local short="n:c:a:h"
  local long="vdi:,connect:,action:,help"

  if ! tmp=$(getopt -o "$short" --long "$long" -n "$BASENAME" -- "$@"); then
    exit 1
  fi

  eval set -- "$tmp"
  unset tmp

  while true; do
    case "$1" in
    '-n' | '--vdi' )
      vdi_name="$2"; shift 2
      ;;

    '-c' | '--connect' )
      vdi_connect_uri="$2"; shift 2
      ;;

    '-a' | '--action' )
      vdi_action="$2"; shift 2
      ;;

    '-h' | '--help' )
      _usage "$USAGE" 0
      ;;

    '--' )
      shift; break
      ;;

    * )
      _usage "$USAGE" 1
      ;;
    esac
  done

  if [[ ! -v vdi_name ]]; then
    echo "Error: Must define the name of the VDI VM"
    _usage "$USAGE" 1
  fi

  if [[ ! -v vdi_connect_uri ]]; then
    vdi_connect_uri="qemu:///system"
  fi

  if [[ ! -v vdi_action ]]; then
    vdi_action="start"
  fi

  vdi_virsh_cmd="$(command -v virsh) -q --connect ${vdi_connect_uri}"
  vdi_virtmgr_cmd="$(command -v virt-manager) --connect ${vdi_connect_uri}"
}

vdi_start()
{
  echo "Msg: Starting VDI $vdi_name"
  sudo systemctl restart libvirtd
  sudo systemctl restart virtlogd

  $vdi_virsh_cmd start $vdi_name &> /dev/null
  $vdi_virtmgr_cmd --show-domain-console $vdi_name &> /dev/null
}

vdi_stop()
{
  echo "Msg: Shutting down $vdi_name";
  $vdi_virsh_cmd shutdown $vdi_name &> /dev/null

  # Make sure it shut down
  for ((i=1; i<=5; i++)); do
    if $vdi_virsh_cmd list --state-running --name | grep -q $vdi_name; then
      echo "Msg: ${vdi_name} is shut down."
      break
    fi
    sleep 2
  done

  vdi_pid=$(pgrep -f "$vdi_name")
  if [ -n "$vdi_pid" ]; then
    echo "Msg: Closing window for $vdi_name"
    # Here we have a "Operation not permitted", but the window is still closed.
    kill -s 9 $vdi_pid 2> /dev/null
  fi
}

get_vdi_opts "$@"

if [[ ${vdi_action} = "start" ]]; then
  vdi_start
else
  vdi_stop
fi


