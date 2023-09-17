
.DEFAULT_GOAL := help

.PHONY: test
test:
	@ruby -I src/main src/test/all.rb

.PHONY: setup
setup:
	@bash src/scripts/setup.sh

.PHONY: run
run:
	@ruby -I src/main -r main -e main

