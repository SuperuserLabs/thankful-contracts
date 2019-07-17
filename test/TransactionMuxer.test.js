// Based on: https://medium.com/coinmonks/test-a-smart-contract-with-truffle-3eb8e1929370

const assert = require('assert');

const TransactionMuxer = artifacts.require('TransactionMuxer');

contract('TransactionMuxer', async accounts => {
    let addr_empty = '0x0000000000000000000000000000000000000000';
    let addr_sender = accounts[0];
    let receivers = accounts.slice(1, 9);

    it('send', async () => {
        let muxer = await TransactionMuxer.deployed();
        let totalAmount = 1000;

        let amounts = [];
        for (var i = 0; i < receivers.length; i++) {
            amounts.push(totalAmount / receivers.length);
        }

        let r = await muxer.transferMany(receivers, amounts, {
            from: addr_sender,
            value: totalAmount,
        });
        let gasUsed = r.receipt.gasUsed;
        let savings = 1 - gasUsed / (21000 * receivers.length);
        console.log(
            `Used ${gasUsed} gas for ${
                receivers.length
            } transactions, saving ${Math.round(savings * 100)}%`
        );
    });
});
