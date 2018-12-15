// Based on: https://medium.com/coinmonks/test-a-smart-contract-with-truffle-3eb8e1929370

const assert = require('assert');
//const ganache = require('ganache-cli');
//const Web3 = require('web3');
//const web3 = new Web3(ganache.provider({"default_balance_ether": 1}));

const AddressRegistrar = artifacts.require("AddressRegistrar");
const DonationHandler = artifacts.require("DonationHandler");

contract('AddressRegistrar', async (accounts) => {
    it("print account balances", async () => {
        for(i in [0, 1, 2, 3]) {
            let account_bal = await web3.eth.getBalance(accounts[i]).toString();
            console.log(`Account ${i} (${accounts[i]}): `, account_bal);
        }
    })

    it("donate, associate, and payOut", async () => {
        let registrar = await AddressRegistrar.deployed();
        let dh = await DonationHandler.deployed();

        let verifier = accounts[0];
        let supporter = accounts[1];
        let creator = accounts[2];

        // Donate to email address
        await dh.donate("erik@bjareho.lt", 1000, {from: supporter, value: 1000});

        // Associate email with Ethereum address
        await registrar.associate("erik@bjareho.lt", creator, {from: verifier});

        let balance = (await web3.eth.getBalance(dh.address)).toString();
        assert.equal(balance, "1000");

        await dh.payOut("erik@bjareho.lt", {from: creator});

        // Ensure all was payed out
        balance = (await web3.eth.getBalance(dh.address)).toString();
        assert.equal(balance, "0");
        //assert.equal(instance.valueOf(), 10000, "10000 wasn't in the first account");
        return true;
    });
});
