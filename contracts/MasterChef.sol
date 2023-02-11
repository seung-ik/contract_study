//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./GrayToken.sol";

contract MasterChef is Ownable {
  struct UserInfo {
    uint amount;
    uint rewardDebt;
  }
  struct PoolInfo {
    IERC20 lpToken;
    uint allocPoint;
    uint lastRewardBlock;
    uint accGrayPerShare;
  }
  
  GrayToken public gray;
  address public devaddr;
  uint grayPerBlock;
  uint public startBlock;

  PoolInfo[] public poolInfo;
  mapping(uint => mapping(address => UserInfo)) public userInfo;
  uint public totalAllocPoint = 0;

  event Deposit(address indexed user, uint indexed pid, uint amount);
  event Withdraw(address indexed user, uint indexed pid, uint amount);
  event EmergencyWithdraw(address indexed user, uint indexed pid, uint amount);

  constructor(GrayToken _gray, address _devaddr, uint _grayPerBlock, uint _startBlock){
    gray = _gray;
    devaddr = _devaddr;
    grayPerBlock = _grayPerBlock;
    startBlock = _startBlock;
  }

  function poolLength() external view returns (uint){
    return poolInfo.length;
  }

  function add(uint _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
    if(_withUpdate){
      massUpdatePools();
    }

    uint lastRewardBlock = block.number > startBlock ? block.number : startBlock;
    totalAllocPoint += _allocPoint;
    poolInfo.push(PoolInfo({
      lpToken: _lpToken,
      allocPoint: _allocPoint,
      lastRewardBlock: lastRewardBlock,
      accGrayPerShare: 0
    }));
  }

  // pool 의 allocpoin를 바꿀때
  function set(uint _pid, uint _allocPoint, bool _withUpdate) public onlyOwner {
    if(_withUpdate){
      massUpdatePools();
    }
    uint prevAllocPoint = poolInfo[_pid].allocPoint;
    poolInfo[_pid].allocPoint = _allocPoint;
    if(prevAllocPoint != _allocPoint) {
      totalAllocPoint = totalAllocPoint - prevAllocPoint + _allocPoint;
    }
  }

  function getMultiplier(uint _from, uint _to) public pure returns(uint){
    return _to - _from;
  }
  // 수확하지 않고 남아있는 보상토큰수량
  function pendingGray(uint _pid, address _user) external view returns(uint){
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][_user];

    uint accGrayPerShare = pool.accGrayPerShare;
    uint lpSupply = pool.lpToken.balanceOf(address(this)); //Masterchef 에 해당풀의 토큰페어의 스테이킹된 개수

    if(block.number > pool.lastRewardBlock && lpSupply !=0){
      uint multiplier = getMultiplier(pool.lastRewardBlock, block.number);
      uint grayReward = multiplier * grayPerBlock * pool.allocPoint / totalAllocPoint;
      accGrayPerShare = accGrayPerShare + (grayReward * 1e12 / lpSupply);
    }
    return user.amount * accGrayPerShare / 1e12 - user.rewardDebt;
  }

  function massUpdatePools() public {
    uint length = poolInfo.length;
    for(uint pid=0; pid < length; ++pid){
      updatePool(pid);
    }
  }

  function updatePool(uint _pid) public {
    PoolInfo storage pool = poolInfo[_pid];
    if(block.number <= pool.lastRewardBlock){
      return;
    }
    uint lpSupply = pool.lpToken.balanceOf(address(this));
    if(lpSupply == 0){
      pool.lastRewardBlock = block.number;
      return;
    }

    uint multiplier = getMultiplier(pool.lastRewardBlock, block.number);
    uint grayReward = (multiplier * grayPerBlock * pool.allocPoint) / totalAllocPoint;

    gray.mint(devaddr, grayReward/10);
    gray.mint(address(this),grayReward);

    pool.accGrayPerShare = pool.accGrayPerShare + (grayReward * 1e12/ lpSupply);
  } 

  function deposit(uint _pid, uint _amount) public {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    updatePool(_pid); // 스테이킹 수량 변경시 미리 수확을 한번 해줌

    if(user.amount > 0) {
      uint pending = user.amount * pool.accGrayPerShare / 1e12 - user.rewardDebt;
      if(pending>0){
        gray.transfer(msg.sender, pending);
      }
    }

    if(_amount > 0) {
      pool.lpToken.transferFrom(address(msg.sender), address(this), _amount);
      user.amount += _amount;
    }

    user.rewardDebt = user.amount * pool.accGrayPerShare / 1e12;
  }

  function withdraw(uint _pid, uint _amount) public {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    require(user.amount >= _amount);
    updatePool(_pid);
    uint pending = user.amount * pool.accGrayPerShare /1e12 - user.rewardDebt;
    if(pending > 0){
      gray.transfer(msg.sender,pending);
    }
    if(_amount > 0) {
      user.amount = user.amount - _amount;
      pool.lpToken.transfer(address(msg.sender),_amount);
    }
    user.rewardDebt = user.amount * pool.accGrayPerShare /1e12;
    emit Withdraw(msg.sender, _pid, _amount);
  }

  // 위급할때 스테이킹한거라도 가져가는거 파밍없이 가져가는듯
  function emergencyWithdraw(uint _pid) public {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];

    pool.lpToken.transfer(address(msg.sender),user.amount);
    emit EmergencyWithdraw(msg.sender, _pid, user.amount);
    user.amount = 0;
    user.rewardDebt = 0;
  }

  function dev(address _devaddr) public {
    require(msg.sender == devaddr, "only dev");
    devaddr = _devaddr;
  }
}