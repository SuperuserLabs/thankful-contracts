let AddressRegistrar = artifacts.require("AddressRegistrar");
let DonationHandler = artifacts.require("DonationHandler");

module.exports = async function(deployer) {
    deployer.deploy(AddressRegistrar).then(() => {
        return deployer.deploy(DonationHandler, AddressRegistrar.address);
    });
};
