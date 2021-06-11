// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// interface IERC20 {
//     function totalSupply() external returns (uint);
//     function balanceOf(address tokenOwner) external returns (uint balance);
//     function allowance(address tokenOwner, address spender) external  returns (uint remaining);
//     function transfer(address to, uint tokens) external returns (bool success);
//     function approve(address spender, uint tokens) external returns (bool success);
//     function transferFrom(address from, address to, uint tokens) external returns (bool success);
// }

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

 contract Stake {
    struct weekDetails {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        bool alreadyTransfered;
    }
    
    mapping(string => weekDetails) stake;
    address private _owner;
    address private _SOKUTokenAddr;
    uint256 lockingTime = 30 days;

     modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not owner");
        _;
    }
 
    constructor(address sokuTokenAddr) {
        _owner = msg.sender;
        _SOKUTokenAddr = sokuTokenAddr;
    }

    /**
     * @dev Transfer from owner an amount of SOKU Tokens to lock in this contract.
     */
    function addWeekAmount(string memory weekYear, uint256 amount) public onlyOwner {
        require(amount > 0, 'Stake: Trying to lock 0 (zero) amount');
        
        stake[weekYear].amount = amount;
        stake[weekYear].startTime = block.timestamp;
        stake[weekYear].endTime = block.timestamp + lockingTime;

        IERC20(_SOKUTokenAddr).transferFrom(msg.sender, address(this), amount);
    }   
    
    /**
     * @dev Transfer back after the expiration time.
     */
    function withdraw(string memory weekYear, address destination, uint amount) onlyOwner external {
        require(block.timestamp >= stake[weekYear].endTime, 'Stake: too early');
        require(!stake[weekYear].alreadyTransfered, 'Stake: This amount was already Transfered');
        
        IERC20(_SOKUTokenAddr).transfer(destination, amount);
        stake[weekYear].alreadyTransfered = true;
      }   
      
    /**
     * @dev Getter for a week value.
     */
    function getWeekValue(string memory weekYear) onlyOwner external view returns (uint256) {
        
        return (stake[weekYear].amount);
      }       
      
    /**
     * @dev Checking if an amount is already available as unlocked.
     */
    function isAmountAvailable(string memory weekYear) onlyOwner external view returns (bool){
        require(!stake[weekYear].alreadyTransfered, 'Stake: This amount was already Transfered');
        
        return (block.timestamp >= stake[weekYear].endTime);
      }       
    
 }