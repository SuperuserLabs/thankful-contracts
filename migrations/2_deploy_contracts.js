var AddressRegistrar = artifacts.require("AddressRegistrar");

module.exports = function(deployer) {
    deployer.deploy(AddressRegistrar);
};
