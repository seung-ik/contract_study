// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IFactory.sol";

contract Exchange is ERC20 {
  IERC20 token;
  IFactory factory;
  
  constructor(address _token) ERC20("Gray Uniswap V2", "Guni-V2"){
    token = IERC20(_token);
    factory = IFactory(msg.sender);
  }
  
  function addLiquidity(uint _maxTokens) public payable {
    uint totalLiquidity = totalSupply();
    if(totalLiquidity > 0){
      uint ethReserve = address(this).balance - msg.value;
      uint tokenReserve = token.balanceOf(address(this));
      uint tokenAmount = msg.value * tokenReserve / ethReserve;
      require(tokenAmount <= tokenAmount);
      token.transferFrom(msg.sender, address(this),tokenAmount);
      uint liquidityMinted = totalLiquidity * msg.value / ethReserve;
      _mint(msg.sender, liquidityMinted);
    }else{
      uint tokenAmount = _maxTokens;
      uint initalLiquidity = address(this).balance;
      _mint(msg.sender, initalLiquidity);
      token.transferFrom(msg.sender, address(this), tokenAmount);
    }
  }

  function removeLiquidity(uint _lpTokenAmount) public {
    uint totalLiquidity = totalSupply();
    uint ethAmount = _lpTokenAmount * address(this).balance / totalLiquidity;
    uint tokenAmount = _lpTokenAmount * token.balanceOf(address(this)) / totalLiquidity;

    _burn(msg.sender, _lpTokenAmount);

    payable(msg.sender).transfer(ethAmount);
    token.transfer(msg.sender, tokenAmount);
  }

  //eth > erc20
  function ethToTokenSwap(uint _minTokens) public payable {
    uint256 outputAmount = getOutputAmount(msg.value, address(this).balance - msg.value, token.balanceOf(address(this)));
    require(outputAmount >= _minTokens,"inffucient outputAmount");

    token.transfer(msg.sender, outputAmount);
  }

  //erc20 > eth
  function tokenToEthSwap(uint _tokenSold, uint _minEth) public {
    uint256 outputAmount = getOutputAmount(_tokenSold, token.balanceOf(address(this)), address(this).balance);
    require(outputAmount >= _minEth,"inffucient outputAmount");

    token.transferFrom(msg.sender, address(this), _tokenSold);
    payable(msg.sender).transfer(outputAmount);
  }

  function getOutputAmount(uint inputAmount, uint inputReserve, uint outputReserve) public pure returns(uint) {
    uint inputAmountWithFee = inputAmount * 99;
    uint numerator = outputReserve * inputAmountWithFee;
    uint denominator = inputReserve*100 + inputAmountWithFee;
    return numerator / denominator; // y` = y*x / x+x`
  }
}