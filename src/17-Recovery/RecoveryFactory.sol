// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../Level.sol";
import "./Recovery.sol";

contract RecoveryFactory is Level {
    constructor() Owned(msg.sender) {}
    
    function createInstance(address _player) public payable override returns (address) {
        require(msg.value >= 0.001 ether, "Not enough ether");
        Recovery instance = new Recovery();
        instance.generateToken("SimpleToken", 1 ether);
        address token = computeAddressRecovered(address(instance));
        (bool success, ) = token.call{value: 0.001 ether}("");
        require(success);
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        address tokenLost = computeAddressRecovered(_instance);
        return tokenLost.balance == 0;
    }

    function computeAddressRecovered(address _instance) pure public returns (address addressRecovered) {
        /* For more info on RLP --> https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/
            Address of created contract to recover depends on sender address and the sender nonce
            The sender address are `least_significant_20bytes(keccak256(RLP(sender, nonce)))`
            The whole message is between 0-55 bytes so needs to start with 0x80 as the 

        -- RLP(sender) = (String init + senderLength) + sender, where sender is the _instance address
            - Starts with 0x80 because sender address is bytes20 so is 0-55 bytes long
            - Decimal 20 = 0x14
            - (0x80 + 0x14) + sender = 0x94 + sender
            Total: 21 bytes

        -- RLP(nonce) = nounce
            - EIP-161 makes nonce increment prior to creation:
                - Contract creation just happened in the test so now nonce = 0x01 (single byte)
            Total: 1 byte

        -- Adding all together in the RLP list with bytes22:
            - Combined length of all its items being RLP encoded) is 0-55 bytes long
            - RLP encoding consists of a single byte with value 0xc0 + the length of the list 
            - followed by the concatenation of the RLP encodings of the items.
            - (0xc0 + length) + (RLP(sender), RLP(nonce)) = (0xc0 + Decimal(22bytes)) + RLPs = 0xd6 + RLPs

        -- Encode RLP:
            0xd6 + 0x94 + sender + 0x01
        */
        addressRecovered = address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xd6),   // Total payload size between 0 and 55 bytes
            bytes1(0x94),   // RLP sender size between 0 and 55 bytes
            _instance,      // Sender Address
            bytes1(0x01)    // Sender Nounce
        )))));
    }

    receive() external payable {}
}