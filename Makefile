.PHONY: build test

build:
	npx truffle compile

develop:
	npx truffle develop

ganache:
	npx ganache-cli --port 9545 --networkId 5777

stop-develop:
	kill $$(ps -x | grep ganache | awk '{print $$1;}')

migrate:
	npx truffle migrate

test:
	npx truffle test

clean:
	rm -r build
