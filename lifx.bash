#!/usr/bin/env bash

set -e
set -o pipefail
set -u

: "${LIFX_VENV:=$(pwd)/.venv}"

function fatal_error {
	[[ -z "$*" ]] || echo 1>&2 "[FATAL] $*"
	exit 1
}

function mclarkk_example {
	local -r PY_FILE="$LIFX_VENV/../mclarkk/examples/${1:-}.py"
	[[ -f "$PY_FILE" ]] || fatal_error "missing: $PY_FILE (mclarkk example)"
	shift || true
	exec python3 "$PY_FILE" "$@"
}

function photons_command {
	local -r LIFX_COMMAND="$LIFX_VENV/bin/lifx"
	[[ -x "$LIFX_COMMAND" ]] || fatal_error "no lifx executable (LIFX_VENV=$LIFX_VENV)"
	exec "$LIFX_COMMAND" "$@"
}

function _sane {
	[[ -d "$LIFX_VENV" ]] || fatal_error "missing venv (LIFX_VENV=$LIFX_VENV)"
	# shellcheck source=.venv/bin/activate
	[[ -f "$LIFX_VENV/bin/activate" ]] && source "$LIFX_VENV/bin/activate"

	[[ -f "$LIFX_VENV/bin/lifx" ]] || pip3 install -U pip -r requirements.txt
	[[ -d "$(dirname "$0")/mclarkk/examples" ]] || git submodule update --init
}

function _main {
	_sane
	local -r COMMAND="${1:-command}"
	shift || true
	case "$COMMAND" in
		command) python3 hagemt/tiles.py "$@" ;;
		example) mclarkk_example "$@" ;;
		photons) photons_command "$@" ;;
		usage|*) echo 1>&2 "[USAGE] $0 example breathe_all 2"
	esac
}

_main "$@"
