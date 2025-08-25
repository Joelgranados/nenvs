#!/usr/bin/env bash

: "${CONFDIR:="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"}"
: "${CONF:="${CONFDIR}/iommut.conf"}"
: "${TEST_DIR:="${HOME}/src/iommutests/bdir/tests"}"
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
	_remote_exec "pytest -rs ${TEST_DIR}"
#	_remote_exec "dmesg" | tail -n 20
}

read_opt() {
	local short=""
	local long="run:,kill"

	if ! tmp=$(getopt -o "$short" --long "$long" -n "$BASENAME" -- "$@"); then
		  exit 1
	fi

	eval set -- "$tmp"
	unset tmp
	
	while true; do
		case "$1" in
		'--run' )
			run+=("$2"); shift 2
			;;
		'--kill' )
			trap 'vmctl -c ${CONF} kill' EXIT
			shift
			;;
		'--' )
			shift; break
			;;
		* )
			echo "Input error"
			exit 1
			;;
		esac
	done
}

read_opt "$@"

if [[ -v run ]]; then
	_init_vm
	for func in "${run[@]}"; do
		if [[ "${func}" == "iommut_test_"* ]]; then
			eval "${func}"
		else
			echo "Skipping ${func} as its not defined"
		fi
	done
fi
