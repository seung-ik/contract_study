// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

contract EventTest {
  event NewExchange(string indexed token, uint id);
  uint index;
  mapping(uint=>string) public getExchange;

  function createExchange(string memory _token) public {
    getExchange[++index] = _token;
    emit NewExchange(_token, index);
  }
}