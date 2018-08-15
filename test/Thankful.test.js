// Based on: https://medium.com/coinmonks/test-a-smart-contract-with-truffle-3eb8e1929370

const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
const json = require('./../build/contracts/Thankful.json');

let accounts;
let contract;
let manager;

const interface = json['abi'];
const bytecode = json['bytecode'];

beforeEach(async () => {
      accounts = await web3.eth.getAccounts();
      manager = accounts[0];
      contract = await new web3.eth.Contract(interface)
          .deploy({ data: bytecode })
          .send({ from: manager, gas: '1000000' });
});


describe('Thankful', () => {
	it('deploys a contract', async () => {
		//const contractManager = await contract.methods.manager().call();
		//assert.equal(manager, contractManager, 'The manager is the one who launches the smart contract.');
	});
	//Continue from this line from now on...
});
