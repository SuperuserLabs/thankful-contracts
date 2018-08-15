.PHONY: build test

build:
	npx truffle compile

develop:
	npx truffle develop

stop-develop:
	kill $$(ps -x | grep ganache | awk '{print $$1;}')

test:
	npx truffle test

clean:
	rm -r build
