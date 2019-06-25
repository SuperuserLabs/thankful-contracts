pragma solidity ^0.4.24;

import './AddressRegistrar.sol';

contract DonationHandler {
    address public owner;
    AddressRegistrar public registrar;

    mapping(string => PendingDonations) pending;

    constructor(AddressRegistrar _registrar) public {
        owner = msg.sender;
        registrar = _registrar;
    }

    struct Donation {
        address sender;
        uint amount;
        uint256 expires;
    }

    struct PendingDonations {
        Donation[] donations;
        uint n_pending;
        uint n_donated;
        uint n_refunded;
    }

    // Donate to a creator, add to pending if email has no connected address.
    function donate(string _email, uint32 _expires_in) public payable returns (uint256) {
        require(msg.value > 0);
        address _addr = registrar.getAddressByEmail(_email);
        if(_addr != 0x0) {
            _addr.transfer(msg.value);
            return 0;
        } else {
            uint256 _idx = pending[_email].donations.push(Donation(msg.sender, msg.value, now + _expires_in));
            pending[_email].n_pending++;
            return _idx;
        }
    }

    // Refund pending transaction that has expired
    function refund(string _email, uint32 _idx) public {
        require(now > pending[_email].donations[_idx].expires);
        delete pending[_email].donations[_idx];
        pending[_email].n_refunded++;
    }

    function lastPending(string _email) public constant returns (uint256) {
        return pending[_email].donations.length - 1;
    }

    // Pay out last pending transaction for creator if email has an assigned address
    function payOut(string _email, uint32 _idx) public {
        address _addr = registrar.getAddressByEmail(_email);
        require(_addr != 0x0);

        Donation storage d = pending[_email].donations[_idx];
        if(d.amount != 0x0) {
            _addr.transfer(d.amount);
            delete pending[_email].donations[_idx];
            pending[_email].n_donated++;
        } else {
            revert();
        }
    }
}
