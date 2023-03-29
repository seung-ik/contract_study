// ttot_main.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Concert_V1.sol";

contract Factory_V1 is ERC721URIStorage{
    using Strings for uint256;
    using Counters for Counters.Counter;

    enum TicketStatus { waiting, on, off}
    struct TicketInfo {
        string name;
        uint price;
        uint limitOfDate;
        uint16 availableSeats;
        TicketStatus status;
    }

    address payable owner;
    constructor() ERC721("TicketToToken","TTOT") {
        owner = payable(msg.sender);
    }

    Counters.Counter private _tokenIds;

    function mintTicket(string memory _tokenURI, address _concertAddr) public payable {
        (string name,uint price,uint limitOfDate,uint availableSeats,TicketStatus status) = Concert_V1(_concertAddr).ticketInfo();
        require(price<=msg.value,"not enough money");
        require(availableSeats>0,"sold out");
        require(limitOfDate>block.timestamp,"over time");
        
        _tokenIds.increment();
        uint tokenId = _tokenIds.current();
        _setTokenURI(tokenId, _tokenURI);
        _mint(msg.sender, tokenId);
    }
}