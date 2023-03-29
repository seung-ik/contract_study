// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Factory_V1.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract Concert_V1 is ERC2981 {
    Factory_V1 public ticketFactoryCA;

    enum TicketStatus { waiting, on, off}
    struct TicketInfo {
      string name;
      uint price;
      uint limitOfDate;
      uint16 availableSeats;
      TicketStatus status;
    }
    TicketInfo public ticketInfo;

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    constructor(uint96 _royaltyFeesInBips, address _nftContractAddress, address _artistAddress, string memory _concertName,uint _price, uint _limitOfDate, uint16 _availableSeats){
      ticketFactoryCA = FACTORY_V1(_nftContractAddress);
      ticketInfo = TicketInfo(_concertName, _price, _limitOfDate,_availableSeats, TicketStatus.on);
      _defaultRoyaltyInfo= RoyaltyInfo(_artistAddress, _royaltyFeesInBips);
    }
    
    // tokenid => price
    mapping(uint => uint) public tokenPrices;

    function setForSale(uint _tokenId, uint _price) public {
      require(ticketFactoryCA.ownerOf(_tokenId)==msg.sender,"Caller is not token owner.");
      require(_price > 0, "Price must be greater than zero.");
      require(tokenPrices[_tokenId] == 0, "Already sale");
      require(ticketFactoryCA.isApprovedForAll(msg.sender, address(this)));

      tokenPrices[_tokenId] = _price;
    }

    function purchase(uint _tokenId) public payable {
      require(ticketFactoryCA.ownerOf(_tokenId) != msg.sender,"Caller is not token owner.");
      require(tokenPrices[_tokenId] > 0, "Not sale.");
      require(tokenPrices[_tokenId] <= msg.value, "Caller sent lower than price.");

      (address artistAddress, uint256 royaltyAmount) = royaltyInfo(_tokenId, msg.value);

      payable(artistAddress).transfer(royaltyAmount);
      payable(ticketFactoryCA.ownerOf(_tokenId)).transfer(msg.value - royaltyAmount);

      ticketFactoryCA.safeTransferFrom(ticketFactoryCA.ownerOf(_tokenId), msg.sender, _tokenId);

      tokenPrices[_tokenId] = 0;
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();
        return (royalty.receiver, royaltyAmount);
    }
}