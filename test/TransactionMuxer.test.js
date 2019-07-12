// Based on: https://medium.com/coinmonks/test-a-smart-contract-with-truffle-3eb8e1929370

const assert = require('assert');

const TransactionMuxer = artifacts.require("TransactionMuxer");

contract('TransactionMuxer', async (accounts) => {
    let addr_empty = "0x0000000000000000000000000000000000000000";
    let addr_sender = accounts[0];
    let receivers = accounts.slice(1, 6);

    it("send", async () => {
        let muxer = await TransactionMuxer.deployed();
        let totalAmount = 1000;
        let amounts = [
            Math.round(0.3 * totalAmount),
            Math.round(0.3 * totalAmount),
            Math.round(0.2 * totalAmount),
            Math.round(0.1 * totalAmount),
            Math.round(0.1 * totalAmount),
        ];
        await muxer.transferMany(receivers, amounts, {from: addr_sender, value: totalAmount})
    })
});
