let AddressRegistrar = artifacts.require("AddressRegistrar");
let DonationHandler = artifacts.require("DonationHandler");
let TransactionMuxer = artifacts.require("TransactionMuxer");

module.exports = function(deployer) {
    deployer.deploy(AddressRegistrar).then(() => {
        return deployer.deploy(DonationHandler, AddressRegistrar.address);
    }).then(() => {
        return deployer.deploy(TransactionMuxer);
    });
};
