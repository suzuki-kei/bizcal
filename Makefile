
.DEFAULT_GOAL := help

.PHONY: setup
setup:
	@bash src/scripts/setup.sh

.PHONY: run
run:
	@ruby -I src/main -r main -e main

