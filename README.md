thankful-contracts
==================

Ethereum contracts used by Thankful.

[![Build Status](https://travis-ci.org/SuperuserLabs/thankful-contracts.svg?branch=master)](https://travis-ci.org/SuperuserLabs/thankful-contracts)

## How to develop

```sh
npm install
make build
make develop  # start a development chain
make migrate  # runs migrations
make test  # run tests
```


For details about how to debug, see this guide: https://truffleframework.com/tutorials/debugging-a-smart-contract

Summary of the guide:

```sh
npx truffle debug <txid>
```


## Guides

 - [OpenZeppelin intro to smart contracts](https://blog.zeppelin.solutions/the-hitchhikers-guide-to-smart-contracts-in-ethereum-848f08001f05)
 - [Guide to the ERC721 spec](https://medium.com/blockchannel/walking-through-the-erc721-full-implementation-72ad72735f3c)
 - [OpenZeppelin docs](https://openzeppelin.org/api/)
 - [OpenZeppelin ERC721 token example](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/07020e954475a4fdd36e0252e88717b60f790b71/contracts/token/ERC721/ERC721Token.sol)
