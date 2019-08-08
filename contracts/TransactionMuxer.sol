pragma solidity ^0.5.0;

contract TransactionMuxer {
    event TxOutput(address output, uint amount);

    function transferMany(address payable[] memory _outputs, uint[] memory _amounts) public payable {
        // This check won't work, because there is no sum() function
        // require(msg.value == sum(_amounts));
        require(_outputs.length == _amounts.length);
        uint valueSent = 0;
        for (uint i=0; i<_outputs.length; i++) {
            _outputs[i].transfer(_amounts[i]);
            valueSent += _amounts[i];
            emit TxOutput(_outputs[i], _amounts[i]);
        }
        require(valueSent == msg.value);
    }
}
