#!/usr/bin/env bash

: "${CONFDIR:="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"}"
: "${CONF:="${CONFDIR}/iommutci.conf"}"
: "${EXIT_ON_ERROR:=0}"

_exec() {
	local cmd="$1"
	eval "${cmd}"
	res=$?
	if [[ $res != 0 && ${EXIT_ON_ERROR} == 1 ]]; then
		echo -e "error cmd (${cmd}) \n err: $res"
		exit 1
	fi
}

_remote_exec() {
	local cmd="$1"
	local remote_cmd="vmctl -c ${CONF} ssh --wait \"${cmd}\""
	_exec "${remote_cmd}"
}

_init_vm() {
	_exec "vmctl -c ${CONF} run -b"
}

iommut_test_all() {
	_remote_exec "iommut"
}

_init_vm
iommut_test_all
vmctl -c ${CONF} kill
