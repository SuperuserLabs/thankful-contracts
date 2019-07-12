pragma solidity ^0.4.24;

import './AddressRegistrar.sol';

// TODO: Add escape-hatch (clear mapping, and self-destruct?)
contract AddressRegistrar {
    // TODO: Make contract extend Ownable (for onlyOwner modifiers etc.)
    // https://medium.com/codexprotocol/a-simple-framework-for-deploying-ownable-contracts-63ed4bd3c657
    // The owner is the verifier
    address public owner;

    mapping(string => Creator) creators;

    constructor() public {
        owner = msg.sender;
    }

    struct Creator {
        address addr;
    }

    // Associate an email with a wallet address
    function associate(string _email, address _address) public {
        require(msg.sender == owner);
        creators[_email].addr = _address;
    }

    // Deassociate an email
    function deassociate(string _email) public {
        require(msg.sender == owner);
        delete creators[_email];
    }

    function getAddressByEmail(string _email) public constant returns (address) {
        return creators[_email].addr;
    }
}
