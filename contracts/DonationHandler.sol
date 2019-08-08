pragma solidity ^0.5.0;

import './AddressRegistrar.sol';
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract DonationHandler {
    address public owner;
    AddressRegistrar public registrar;

    mapping(string => PendingDonations) pending;

    event DonationCompleted(address _sender, ERC20 _tokenContract, uint _tokens);
    event DonationPending(address _sender, ERC20 _tokenContract, uint _tokens);

    constructor(AddressRegistrar _registrar) public {
        owner = msg.sender;
        registrar = _registrar;
    }

    struct Donation {
        address sender;
        ERC20 tokenContract;
        uint tokens;
        uint expires;
    }

    struct PendingDonations {
        Donation[] donations;
        uint n_pending;
        uint n_donated;
        uint n_refunded;
    }

    // Donate to a creator, add to pending if email has no connected address.
    function donate(string memory _email, uint _expires_in_seconds, ERC20 _tokenContract, uint _tokens) public returns (uint256) {
        require(_tokenContract.balanceOf(msg.sender) > _tokens && _tokenContract.allowance(msg.sender, address(this)) > _tokens);

        address _addr = registrar.getAddressByEmail(_email);
        if(_addr != address(0x0)) {
            _sendDonation(msg.sender, _addr, _tokenContract, _tokens);
            return 0;
        } else {
            _addPending(_email, _expires_in_seconds, _tokenContract, _tokens);
        }
    }

    function _sendDonation(address _from, address _to, ERC20 _tokenContract, uint _tokens) private {
        _tokenContract.transferFrom(_from, _to, _tokens);
        emit DonationCompleted(_from, _tokenContract, _tokens);
    }

    function _addPending(string memory _email, uint _expires_in_seconds, ERC20 _tokenContract, uint _tokens) private returns (uint256) {
        uint256 _idx = pending[_email].donations.push(Donation(msg.sender, _tokenContract, _tokens, block.timestamp + _expires_in_seconds * 1 seconds));
        pending[_email].n_pending++;
        emit DonationPending(msg.sender, _tokenContract, _tokens);
        return _idx;
    }

    // Refund pending transaction that has expired
    function refund(string memory _email, uint32 _idx) public {
        require(now >= pending[_email].donations[_idx].expires);
        delete pending[_email].donations[_idx];
        pending[_email].n_refunded++;
        pending[_email].n_pending--;
    }

    // Returns the index of the last added pending donation (might already be fulfilled)
    function lastPending(string memory _email) public view returns (uint256) {
        return pending[_email].donations.length - 1;
    }

    // Pay out last pending transaction for creator if email has an assigned address
    function payOut(string memory _email, uint32 _idx) public {
        address _addr = registrar.getAddressByEmail(_email);
        require(_addr != address(0x0));

        Donation storage d = pending[_email].donations[_idx];
        if(d.tokens > 0) {
            _sendDonation(d.sender, _addr, d.tokenContract, d.tokens);
            delete pending[_email].donations[_idx];
            pending[_email].n_donated++;
            pending[_email].n_pending--;
        } else {
            revert();
        }
    }
}
