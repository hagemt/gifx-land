PYTHON3 := $(shell command -v python3)

export PIPENV_VENV_IN_PROJECT=.venv

demo: venv
	./lifx.bash example get_color_all 1 # will source: .venv/bin/activate
.PHONY: demo

venv:
	[[ -x "$(PYTHON3)" ]] # export PYTHON3=... # to customize; default: use PATH
	[[ -d .venv ]] || "$(PYTHON3)" -m venv .venv # LIFX_VENV=$(shell pwd)/.venv
.PHONY: venv
