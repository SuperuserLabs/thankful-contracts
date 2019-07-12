pragma solidity ^0.4.24;

import './AddressRegistrar.sol';

contract DonationHandler {
    address public owner;
    AddressRegistrar public registrar;

    mapping(string => PendingDonations) pending;

    event DonationCompleted(address _sender, uint _value);
    event DonationPending(address _sender, uint _value);

    constructor(AddressRegistrar _registrar) public {
        owner = msg.sender;
        registrar = _registrar;
    }

    struct Donation {
        address sender;
        uint value;
        uint expires;
    }

    struct PendingDonations {
        Donation[] donations;
        uint n_pending;
        uint n_donated;
        uint n_refunded;
    }

    // Donate to a creator, add to pending if email has no connected address.
    function donate(string _email, uint _expires_in_seconds) public payable returns (uint256) {
        require(msg.value > 0);
        address _addr = registrar.getAddressByEmail(_email);
        if(_addr != 0x0) {
            _addr.transfer(msg.value);
            emit DonationCompleted(msg.sender, msg.value);
            return 0;
        } else {
            uint256 _idx = pending[_email].donations.push(Donation(msg.sender, msg.value, block.timestamp + _expires_in_seconds * 1 seconds));
            pending[_email].n_pending++;
            emit DonationPending(msg.sender, msg.value);
            return _idx;
        }
    }

    // Refund pending transaction that has expired
    function refund(string _email, uint32 _idx) public {
        require(now >= pending[_email].donations[_idx].expires);
        Donation storage d = pending[_email].donations[_idx];
        d.sender.transfer(d.value);
        delete pending[_email].donations[_idx];
        pending[_email].n_refunded++;
        pending[_email].n_pending--;
    }

    // Returns the index of the last added pending donation (might already be fulfilled)
    function lastPending(string _email) public constant returns (uint256) {
        return pending[_email].donations.length - 1;
    }

    // Pay out last pending transaction for creator if email has an assigned address
    function payOut(string _email, uint32 _idx) public {
        address _addr = registrar.getAddressByEmail(_email);
        require(_addr != 0x0);

        Donation storage d = pending[_email].donations[_idx];
        if(d.value != 0x0) {
            _addr.transfer(d.value);
            emit DonationCompleted(d.sender, d.value);
            delete pending[_email].donations[_idx];
            pending[_email].n_donated++;
            pending[_email].n_pending--;
        } else {
            revert();
        }
    }
}
