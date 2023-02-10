// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingRewards is Ownable {
  IERC20 public stakingToken;
  IERC20 public rewardsToken;

  uint public rewardRate = 0;
  uint public rewardsDuration = 365 days;
  uint public periodFinish = 0;
  uint public lastUpdateTime;
  uint public rewardPerTokenStored;

  mapping(address => uint) public userRewardPerTokenPaid;
  mapping(address => uint) public rewards;

  uint private _totalSupply;

  mapping(address => uint) private _balances;

  constructor(address _rewardToken, address _stakingToken) {
    rewardsToken = IERC20(_rewardToken);
    stakingToken = IERC20(_stakingToken);
  }

  function totalSupply() external view returns(uint) {
    return _totalSupply;
  }
  function balanceOf(address account) external view returns(uint) {
    return _balances[account];
  }

  function stake(uint amount) external updateReward(msg.sender){
    require(amount > 0,"Cannot stake 0");
    _totalSupply += amount;
    _balances[msg.sender] += amount;
    stakingToken.transferFrom(msg.sender, address(this), amount);
  }

  function withdraw(uint amount) public updateReward(msg.sender){
    require(amount >0, "Cannot withdraw 0");
    _totalSupply -= amount;
    _balances[msg.sender] -= amount;
    stakingToken.transfer(msg.sender, amount);
  }

  function getReward() public updateReward(msg.sender){
    uint reward = rewards[msg.sender];
    if(reward>0){
      rewards[msg.sender] = 0;
      rewardsToken.transfer(msg.sender, reward);
    }
  }

  function notifyRewardAmount(uint reward) external onlyOwner updateReward(address(0)){
    if(block.timestamp >= periodFinish){
      //reward 12536000 라면 1초에 한개의 리워드코인이 분배된다.
      rewardRate = reward / rewardsDuration;
    }else {
      // 스테이킹 종료전 추가로 리워드 배정하는경우(리워드풀에)
      uint remaining = periodFinish - block.timestamp;
      uint leftover = remaining * rewardRate;
      rewardRate = reward + leftover /rewardsDuration;
    }
    uint balance = rewardsToken.balanceOf(address(this));
    require(rewardRate * rewardsDuration <= balance,"Proviede reward Too high");

    lastUpdateTime = block.timestamp;
    periodFinish = block.timestamp;
  }

  function lastTimeRewardApplicable() public view returns(uint) {
    return block.timestamp < periodFinish ? block.timestamp : periodFinish;
  }

  function rewardPerToken() public view returns (uint) {
    if(_totalSupply == 0){
      return rewardPerTokenStored;
    }

    return rewardPerTokenStored + (rewardRate * (lastTimeRewardApplicable() - lastUpdateTime) * 1e18 / _totalSupply);
  }

  function earned(address account) public view returns (uint){
    return _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18 + rewards[account];
  }

  modifier updateReward(address account) {
    lastUpdateTime = lastTimeRewardApplicable();
    rewardPerTokenStored = rewardPerToken(); // 전체 스테이킹 수량 변경시마다 변경
    if(account != address(0)){
      rewards[account] = earned(account);
      userRewardPerTokenPaid[account] = rewardPerTokenStored; // 나의 스테이킹 수량 변경시마다 변경
    }
    _;
  }
}