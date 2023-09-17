
.DEFAULT_GOAL := test

.PHONY: test
test:
	@ruby -I src/main -I src/test src/test/all.rb

