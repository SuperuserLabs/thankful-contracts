// Based on: https://medium.com/coinmonks/test-a-smart-contract-with-truffle-3eb8e1929370

const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const AddressRegistrar = artifacts.require("AddressRegistrar");

contract('AddressRegistrar', async (accounts) => {
    it("donate, associate, and payOut", async () => {
        let instance = await AddressRegistrar.deployed();
        console.log(instance);
        console.log(accounts[0])
        await instance.donate("erik@bjareho.lt", 1000, {from: accounts[0], value: 1000});
        //await instance.associate("erik@bjareho.lt", accounts[0], {from: accounts[0]});
        let balance = await web3.eth.getBalance(instance.address);
        console.log(balance);
        let account0_bal = await web3.eth.getBalance(accounts[0]);
        console.log(account0_bal);
        //await instance.payOut.call("erik@bjareho.lt");
        return true;
        //assert.equal(instance.valueOf(), 10000, "10000 wasn't in the first account");
    });
});
