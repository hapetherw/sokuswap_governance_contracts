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

/**
 * @title Rewards.sol
 * @dev This contract allows to split SOKU tokens payments among a group of accounts who participate in SOKU exchange
 * making at least 03 swaps in a week, and hodl of SOKU tokens.
 * The split is equal parts for all participants who acomplish above rules.
 * `Rewards.sol` follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {getWeekReward}
 * function.
 */
 
 contract Rewards {
    struct weekDetails {
        uint256 balance;
        uint256 totalParcicipants;
        mapping(address => bool) participants;
        mapping(address => bool) participantPayed;
        bool isClosedForWithdraws;
    }
    
    mapping(string => weekDetails) rewards;
    address private _owner;
    address private _admin;
    address private _SOKUTokenAddr;

     modifier onlyOwner() {
        require((msg.sender == _owner), "Caller is not owner");
        _;
    }
    
     modifier onlyOwnerOrAdmin() {
        require((msg.sender == _owner) || (msg.sender == _owner), "Caller is not owner or admin");
        _;
    }    
 
    constructor(address sokuTokenAddr){ //, address admin) {
        _owner = msg.sender;
        // _admin = admin;
        _SOKUTokenAddr = sokuTokenAddr;
    }
    
      /**
     * @dev After transfer the Rewards balance to this contract, the Admin must set how much is available for
     * a specific week.
     */
    function addWeekBalance(string memory weekYear, uint256 balance) public onlyOwner {
        rewards[weekYear].balance = balance;
    }
    
    /**
     * @dev Getter for the total reward balance for a week.
     */
    function totalWeekBalance(string memory weekYear) public view returns (uint256) {
        return rewards[weekYear].balance;
    }

    /**
     * @dev admin sets here all participants of the week.
     */
    function addWeekParticipant(string memory weekYear, address participant) public onlyOwnerOrAdmin {
        require(participant != address(0), "Rewards: account is the zero address");
        require(!rewards[weekYear].participants[participant], "Rewards: participant is already in the list for this week");
        
        rewards[weekYear].participants[participant] = true;
        rewards[weekYear].totalParcicipants += 1;
    }
    
    /**
     * @dev Getter for the total of wallets can claim for the reward.
     */
    function totalWeekParticipants(string memory weekYear) public view returns (uint256) {
        return rewards[weekYear].totalParcicipants;
    }
    
    /**
     * @dev Getter for check if an user is allowed to claim the reward for a week.
     */
    function amIParticipating(string memory weekYear) public view returns (bool) {
        return rewards[weekYear].participants[msg.sender];
    }    
    
     /**
     * @dev Triggers a transfer to msg.sender of the amount of SOKU Tokens they are owed.
     */
    function getWeekReward(string memory weekYear) public {
        uint256 amount = getWeekRewardValue(weekYear);
        
        require(rewards[weekYear].participants[msg.sender], "Rewards: participant is not in the list for this week");
        require(!rewards[weekYear].participantPayed[msg.sender], "Rewards: participant already received reward this week");
        require(!rewards[weekYear].isClosedForWithdraws, "Rewards: This week is over! - No withdraw is allowed anymore");
        require(IERC20(_SOKUTokenAddr).balanceOf(address(this)) >= amount, "Rewards: not enough balance to withdraw");
        
        
        IERC20(_SOKUTokenAddr).transfer(msg.sender, amount);
        rewards[weekYear].participantPayed[msg.sender] = true;
    }
    
     /**
     * @dev Getter how much is the value by participants in a week.
     */    
    function getWeekRewardValue(string memory weekYear) public view returns (uint256) {
        
        return (rewards[weekYear].balance / rewards[weekYear].totalParcicipants);
    }
    
     /**
     * @dev Set this week for not allow any withdraw.
     */    
    function setWeekClosedForWithdraws(string memory weekYear) onlyOwner public {
        
        rewards[weekYear].isClosedForWithdraws = true;
    }    

     /**
     * @dev 
     */    
    function setWeekOpenForWithdraws(string memory weekYear) onlyOwner public {
        
        rewards[weekYear].isClosedForWithdraws = false;
    }     
     /**
     * @dev allow owner withdraw the balance.
     */    
    function withdraw(uint256 amount) onlyOwner public {
        require(IERC20(_SOKUTokenAddr).balanceOf(address(this)) >= amount, "Rewards: not enough balance to withdraw");
        
        IERC20(_SOKUTokenAddr).transfer(msg.sender, amount);
    }

     /**
     * @dev 
     */ 
    function checkBalance() public view returns (uint256) {
        uint256 bal = IERC20(_SOKUTokenAddr).balanceOf(address(this));
        return bal;
    }  
    
 }