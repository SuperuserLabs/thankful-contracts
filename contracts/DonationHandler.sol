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
        uint refunded;
    }

    // Donate to a creator, add to pending if email has no connected address.
    function donate(string _email, uint32 _expires_in) public payable {
        require(msg.value > 0);
        address _addr = registrar.getAddressByEmail(_email);
        if(_addr != 0x0) {
            _addr.transfer(msg.value);
        } else {
            pending[_email].donations.push(Donation(msg.sender, msg.value, now + _expires_in));
            pending[_email].n_pending++;
        }
    }

    // Refund pending transaction that has expired
    function refund(string _email, uint32 _pending_idx) public {
        require(now > pending[_email].donations[_pending_idx].expires);
        delete pending[_email].donations[_pending_idx];
        pending[_email].refunded++;
    }

    // Pay out last pending transaction for creator if email has an assigned address
    function payOut(string _email) public returns (bool) {
        address _addr = registrar.getAddressByEmail(_email);
        require(_addr != 0x0 && pending[_email].n_pending > 0);
        Donation storage d = pending[_email].donations[idx];
        if(d.amount != 0x0) {
            uint idx = pending[_email].n_pending - 1;
            _addr.transfer(d.amount);
            return true;
        } else {
            pending[_email].n_pending--;
            return false;
        }
    }
}
