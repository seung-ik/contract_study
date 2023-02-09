// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IExchange.sol";

contract Exchange is ERC20 {
  event TokenPurchase(address indexed buyer, uint eth_sold, uint tokens_bought);
  event EthPurchase(address indexed buyer, uint token_sold, uint eth_bought);
  event AddLiquidity(address indexed provider, uint eth_amount, uint token_amount);
  event RemoveLiquidity(address indexed provider, uint eth_amount, uint token_amount);
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
      emit AddLiquidity(msg.sender , msg.value, tokenAmount);
    }else{
      uint tokenAmount = _maxTokens;
      uint initalLiquidity = address(this).balance;
      _mint(msg.sender, initalLiquidity);
      token.transferFrom(msg.sender, address(this), tokenAmount);
      emit AddLiquidity(msg.sender , msg.value, tokenAmount);
    }
  }

  function removeLiquidity(uint _lpTokenAmount) public {
    require(_lpTokenAmount > 0);
    uint totalLiquidity = totalSupply();
    uint ethAmount = _lpTokenAmount * address(this).balance / totalLiquidity;
    uint tokenAmount = _lpTokenAmount * token.balanceOf(address(this)) / totalLiquidity;

    _burn(msg.sender, _lpTokenAmount);

    payable(msg.sender).transfer(ethAmount);
    token.transfer(msg.sender, tokenAmount);

    emit RemoveLiquidity(msg.sender , ethAmount, tokenAmount);
  }

  //eth > erc20
  function ethToTokenSwap(uint _minTokens) public payable {
    ethToToken(_minTokens, msg.sender);
  }

  function ethToTokenTransfer(uint _minTokens, address _recipient) public payable {
    require(_recipient != address(0));
    ethToToken(_minTokens, _recipient);
  }

  function ethToToken(uint _minTokens, address _recipient) private {
    uint256 outputAmount = getOutputAmountWithFee(msg.value, address(this).balance - msg.value, token.balanceOf(address(this)));
    require(outputAmount >= _minTokens,"inffucient outputAmount");

    emit TokenPurchase(_recipient, msg.value, outputAmount);
    IERC20(token).transfer(_recipient, outputAmount);
  }

  //erc20 > eth
  function tokenToEthSwap(uint _tokenSold, uint _minEth) public {
    uint256 outputAmount = getOutputAmountWithFee(_tokenSold, token.balanceOf(address(this)), address(this).balance);

    require(outputAmount >= _minEth,"inffucient outputAmount");

    emit EthPurchase(msg.sender, _tokenSold, outputAmount);
    token.transferFrom(msg.sender, address(this), _tokenSold);
    payable(msg.sender).transfer(outputAmount);
  }

  //token > token
  function tokenToTokenSwap(uint _tokenSold, uint _minTokenBought, uint _minEthbought, address _tokenAddress) public {
    address toTokenExchangeAddress = factory.getExchange(_tokenAddress);
    uint ethOutputAmount = getOutputAmountWithFee(_tokenSold, token.balanceOf(address(this)), address(this).balance);

    require(ethOutputAmount > _minEthbought);

    IERC20(token).transferFrom(msg.sender, address(this), _tokenSold);
    IExchange(toTokenExchangeAddress).ethToTokenTransfer{ value: ethOutputAmount }(_minTokenBought, msg.sender);
  }

  function getOutputAmountWithFee(uint inputAmount, uint inputReserve, uint outputReserve) public pure returns(uint) {
    uint inputAmountWithFee = inputAmount * 99;
    uint numerator = outputReserve * inputAmountWithFee;
    uint denominator = inputReserve*100 + inputAmountWithFee;
    return numerator / denominator; // y` = y*x / x+x`
  }
}