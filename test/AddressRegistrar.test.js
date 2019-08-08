// Based on: https://medium.com/coinmonks/test-a-smart-contract-with-truffle-3eb8e1929370

const assert = require('assert');
//const ganache = require('ganache-cli');
//const Web3 = require('web3');
//const web3 = new Web3(ganache.provider({"default_balance_ether": 1}));

const AddressRegistrar = artifacts.require('AddressRegistrar');
const DonationHandler = artifacts.require('DonationHandler');

// Token used in testing
const TestToken = artifacts.require('TestToken');

let email_erik = 'erik@bjareho.lt';
let email_test = 'test@example.com';

let one_day = 24 * 60 * 60;

contract('AddressRegistrar', async accounts => {
    let addr_empty = '0x0000000000000000000000000000000000000000';
    let addr_verifier = accounts[0];
    let addr_supporter = accounts[1];
    let addr_creator = accounts[2];

    beforeEach(async () => {
        let reg = await AddressRegistrar.deployed();
        let dh = await DonationHandler.deployed();
        let testtoken = await TestToken.deployed();

        await Promise.all(
            [email_erik, email_test].map(async email => {
                await reg.deassociate(email).catch(() => {});
            })
        );

        // Distribute test tokens to all addresses
        await Promise.all(
            accounts.slice(1).map(async acc => {
                await testtoken.transfer(acc, 10000, { from: accounts[0] });
                await testtoken.approve(dh.address, 10000, { from: acc });
            })
        );
        //console.log("Deassociated all")
    });

    it('print account balances', async () => {
        let testtoken = await TestToken.deployed();
        for (i in [0, 1, 2, 3]) {
            let account_bal = (await testtoken.balanceOf(
                accounts[i]
            )).toString();
            console.log(`Account ${i} (${accounts[i]}): `, account_bal);
        }
    });

    it('associate, getAddress, deassociate', async () => {
        let reg = await AddressRegistrar.deployed();
        assert.equal(addr_empty, await reg.getAddressByEmail(email_erik));

        await reg.associate(email_erik, addr_creator, { from: addr_verifier });
        assert.equal(addr_creator, await reg.getAddressByEmail(email_erik));

        await reg.deassociate(email_erik);
        assert.equal(addr_empty, await reg.getAddressByEmail(email_erik));
    });

    it('unauthorized associate', async () => {
        let reg = await AddressRegistrar.deployed();

        try {
            await reg.associate(email_erik, addr_creator, {
                from: addr_supporter,
            });
        } catch {
            return true;
        }
        assert.fail('Unauthorized associate was successful');
        return false;
    });

    it('donate, associate, and payOut', async () => {
        let testtoken = await TestToken.deployed();
        let registrar = await AddressRegistrar.deployed();
        let dh = await DonationHandler.deployed();

        console.log(1);

        // Donate to email address
        await dh.donate(email_erik, one_day, testtoken.address, 1000, {
            from: addr_supporter,
        });
        await dh.donate(email_erik, one_day, testtoken.address, 2000, {
            from: addr_supporter,
        });

        console.log(2);

        // Associate email with Ethereum address
        await registrar.associate(email_erik, addr_creator, {
            from: addr_verifier,
        });

        // Assert balance
        //assert.equal(
        //    (await web3.eth.getBalance(dh.address)).toString(),
        //    '3000'
        //);

        async function payOutAll(email) {
            let pending_idx = (await dh.lastPending(email, {
                from: addr_supporter,
            })).toString();
            for (let i = Number(pending_idx); i >= 0; i--) {
                console.log('Paying out pending #' + i + ' for ' + email);
                try {
                    await dh.payOut(email, i, { from: addr_creator });
                } catch {
                    console.log(' ↪ Already paid out');
                }
            }
            //console.log("Paid out all for " + email);
        }

        // Pay out all
        await payOutAll(email_erik);
        await payOutAll(email_erik);

        console.log(3);

        // Ensure that donations can still be made after a donation/payout cycle
        let email_test = 'tester@example.com';
        await dh.donate(email_test, one_day, testtoken.address, 1000, {
            from: addr_supporter,
        });
        //assert.equal(
        //    (await web3.eth.getBalance(dh.address)).toString(),
        //    '1000'
        //);
        await registrar.associate(email_test, addr_creator, {
            from: addr_verifier,
        });
        await payOutAll(email_test);

        // Ensure all was payed out
        // TODO: Check that token balances are correct
        balance = (await web3.eth.getBalance(dh.address)).toString();
        assert.equal(balance, '0');

        return true;
    });

    it('donate and refund expired transaction', async () => {
        let testtoken = await TestToken.deployed();
        let registrar = await AddressRegistrar.deployed();
        let dh = await DonationHandler.deployed();

        await dh.donate(email_erik, 0, testtoken.address, 1000, {
            from: addr_supporter,
        });
        let last_pending = (await dh.lastPending(email_erik, {
            from: addr_supporter,
        })).toString();
        await dh.refund(email_erik, last_pending);

        // Ensure all was payed out
        balance = (await web3.eth.getBalance(dh.address)).toString();
        assert.equal(balance, '0');

        return true;
    });

    it('donate and fail to refund non-expired transaction', async () => {
        let testtoken = await TestToken.deployed();
        let registrar = await AddressRegistrar.deployed();
        let dh = await DonationHandler.deployed();

        await dh.donate(email_erik, one_day, testtoken.address, 1000, {
            from: addr_supporter,
        });
        let last_pending = (await dh.lastPending(email_erik, {
            from: addr_supporter,
        })).toString();
        try {
            await dh.refund(email_erik, last_pending);
        } catch {
            //console.log("Exception thrown")
            return true;
        }
        assert.fail('Expected throw not received');
        return false;
    });
});
