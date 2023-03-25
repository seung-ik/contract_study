// ttot_host.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Concert_V1 {
    uint public val;

    function increase() external {
      val += 1;
    }
}