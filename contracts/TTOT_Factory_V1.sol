// ttot_main.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TTOT_FACTORY_V1 is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;

    address payable owner;
    constructor() ERC721("TicketToToken","TTOT") {
        owner = payable(msg.sender);
    }

    Counters.Counter private _tokenIds;

    function mintTicket(string memory _tokenURI) public payable {
        // require를 통해서 티켓가격 concert별로 조회이후 msg.value 와 비교 필요함
        _tokenIds.increment();
        uint tokenId = _tokenIds.current();
        // concert ca 에 좌석수 체크
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
    }
}