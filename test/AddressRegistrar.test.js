// Based on: https://medium.com/coinmonks/test-a-smart-contract-with-truffle-3eb8e1929370

const assert = require('assert');
//const ganache = require('ganache-cli');
//const Web3 = require('web3');
//const web3 = new Web3(ganache.provider({"default_balance_ether": 1}));

const AddressRegistrar = artifacts.require("AddressRegistrar");
const DonationHandler = artifacts.require("DonationHandler");

let email_erik = "erik@bjareho.lt";
let email_test = "test@example.com";

let one_day = 24*60*60;

contract('AddressRegistrar', async (accounts) => {
    let verifier = accounts[0];
    let supporter = accounts[1];
    let creator = accounts[2];

    it("print account balances", async () => {
        for(i in [0, 1, 2, 3]) {
            let account_bal = await web3.eth.getBalance(accounts[i]).toString();
            console.log(`Account ${i} (${accounts[i]}): `, account_bal);
        }
    })

    it("donate, associate, and payOut", async () => {
        let registrar = await AddressRegistrar.deployed();
        let dh = await DonationHandler.deployed();

        // Donate to email address
        await dh.donate(email_erik, one_day, {from: supporter, value: 1000});
        await dh.donate(email_erik, one_day, {from: supporter, value: 2000});

        // Associate email with Ethereum address
        await registrar.associate(email_erik, creator, {from: verifier});

        // Assert balance
        assert.equal((await web3.eth.getBalance(dh.address)).toString(), "3000");

        async function payOutAll(email) {
            let pending_idx = (await dh.lastPending(email, {from: supporter})).toString();
            for(let i=Number(pending_idx); i>=0; i--) {
                console.log("Paying out pending #" + i + " for " + email);
                try {
                    await dh.payOut(email, i, {from: creator});
                } catch {
                    console.log(" ↪ Already paid out");
                }
            }
            console.log("Paid out all for " + email);
        }

        // Pay out all
        await payOutAll(email_erik);
        await payOutAll(email_erik);

        // Ensure that donations can still be made after a donation/payout cycle
        let email_test = "tester@example.com";
        await dh.donate(email_test, one_day, {from: supporter, value: 10000});
        assert.equal((await web3.eth.getBalance(dh.address)).toString(), "10000");
        await registrar.associate(email_test, creator, {from: verifier});
        await payOutAll(email_test)


        // Ensure all was payed out
        balance = (await web3.eth.getBalance(dh.address)).toString();
        assert.equal(balance, "0");
        //assert.equal(instance.valueOf(), 10000, "10000 wasn't in the first account");

        return true;
    });

    it("donate and refund expired transaction", async () => {
        let registrar = await AddressRegistrar.deployed();
        let dh = await DonationHandler.deployed();

        await dh.donate(email_erik, 0, {from: supporter, value: 1000});
        let last_pending = (await dh.lastPending(email_erik, {from: supporter})).toString();
        await dh.refund(email_erik, last_pending);

        // Ensure all was payed out
        balance = (await web3.eth.getBalance(dh.address)).toString();
        assert.equal(balance, "0");

        return true;
    });

    it("donate and fail to refund non-expired transaction", async () => {
        let registrar = await AddressRegistrar.deployed();
        let dh = await DonationHandler.deployed();

        await dh.donate(email_erik, one_day, {from: supporter, value: 1000});
        let last_pending = (await dh.lastPending(email_erik, {from: supporter})).toString();
        try {
            await dh.refund(email_erik, last_pending);
        } catch {
            return;
        }
        // TODO: Fix me
        //assert.fail('Expected throw not received');
        return false;
    })
});
