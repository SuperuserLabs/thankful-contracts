pragma solidity ^0.4.24;

// TODO: Refactor into Donator and AddressRegistrar
contract Thankful {
    address verifier;

    mapping(string => PendingDonations) pending;
    mapping(string => Creator) creators;

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

    /// Donate to a creator, add to pending if email has no connected address.
    function donate(string _email, uint32 _expires_in) public payable {
        if(creators[_email].addr != 0x0) {
            // TODO: Send donation directly
        } else {
            pending[_email].donations.push(Donation(msg.sender, msg.value, block.timestamp + _expires_in));
        }
    }

    // Associate an email with a wallet address
    function associate(string _email, address _address) public {
        if(msg.sender == verifier) {
            creators[_email].addr = _address;
        }
    }

    // Refund pending transaction that has expired
    function refund(string _email, uint32 _pending_idx) public {
        require(pending[_email].donations[_pending_idx].expires < now);
        delete pending[_email].donations[_pending_idx];
        pending[_email].refunded += 1;
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