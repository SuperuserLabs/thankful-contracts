pragma solidity ^0.4.24;

// TODO: Refactor out parts relating to actually making donations (that are awaiting an address)
contract AddressRegistrar {
    // TODO: Assign verifier (make contract Ownable)
    // https://medium.com/codexprotocol/a-simple-framework-for-deploying-ownable-contracts-63ed4bd3c657
    // The owner is the verifier
    address public owner;

    mapping(string => PendingDonations) pending;
    mapping(string => Creator) creators;

    constructor() public {
        owner = msg.sender;
    }

    struct Creator {
        address addr;
    }

    struct Donation {
        address sender;
        uint amount;
        uint256 expires;
    }

    struct PendingDonations {
        Donation[] donations;
        uint n_pending;
        uint refunded;
    }

    // Donate to a creator, add to pending if email has no connected address.
    function donate(string _email, uint32 _expires_in) public payable {
        require(msg.value > 0);
        if(creators[_email].addr != 0x0) {
            creators[_email].addr.transfer(msg.value);
        } else {
            pending[_email].donations.push(Donation(msg.sender, msg.value, now + _expires_in));
            pending[_email].n_pending++;
        }
    }

    // Associate an email with a wallet address
    function associate(string _email, address _address) public {
        require(msg.sender == owner);
        creators[_email].addr = _address;
    }

    // Refund pending transaction that has expired
    function refund(string _email, uint32 _pending_idx) public {
        require(now > pending[_email].donations[_pending_idx].expires);
        delete pending[_email].donations[_pending_idx];
        pending[_email].refunded++;
    }

    // Pay out last pending transaction for creator if email has an assigned address
    function payOut(string _email) public returns (bool) {
        address creator_address = creators[_email].addr;
        require(creator_address != 0x0 && pending[_email].n_pending > 0);
        Donation storage d = pending[_email].donations[idx];
        if(d.amount != 0x0) {
            uint idx = pending[_email].n_pending - 1;
            creator_address.transfer(d.amount);
            return true;
        } else {
            pending[_email].n_pending--;
            return false;
        }
    }
}
