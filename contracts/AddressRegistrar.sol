pragma solidity ^0.5.0;

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
    function associate(string memory _email, address _address) public {
        require(msg.sender == owner);
        creators[_email].addr = _address;
    }

    // Deassociate an email
    function deassociate(string memory _email) public {
        require(msg.sender == owner);
        delete creators[_email];
    }

    function getAddressByEmail(string memory _email) public view returns (address) {
        return creators[_email].addr;
    }
}
