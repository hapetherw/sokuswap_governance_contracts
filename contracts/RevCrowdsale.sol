pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract RevCrowdsale {
    address private _ssokuToken;
    address private _accDestination;
    uint256 private _rate;
    uint256 private _totalTokensBack;
    address private _owner;

     modifier onlyOwner() {
        require((msg.sender == _owner), "Caller is not owner");
        _;
    }
    
    constructor(address SSokuToken, address accDestination, uint256 rate){
        _ssokuToken = SSokuToken;
        _accDestination = accDestination;
        _rate = rate;
        _owner = msg.sender;
    }
    

    function addBalance() public payable {}
    
    receive () external payable virtual {}    
    
    function setRate(uint256 newRate) onlyOwner public { //onlyowner
        _rate = newRate;
    }
    
    function getBalance() onlyOwner public view returns (uint256){
        return address(this).balance;
    }
    
    function withdrawBNB() onlyOwner public { //onlyowner
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function sellAll() public {
        uint256 val = IERC20(_ssokuToken).balanceOf(msg.sender);
        _sell(val, msg.sender);
    }
    
    function sellAmount(uint256 amount) public {
        uint256 val = amount;
        _sell(val, msg.sender);
    }
    
    function getTotalTokensBack() onlyOwner public view returns (uint256){
       
        return _totalTokensBack;
    }
    
    function getSSOKUTokens(uint256 amount) onlyOwner public {
       
        IERC20(_ssokuToken).transfer(msg.sender, amount);
    }
    
    function _sell(uint256 amount, address tokenOwner) private returns (bool){
        require(amount > 0, "RevCrowdsale: You need to sell at least some tokens");
        
        uint256 allowance = IERC20(_ssokuToken).allowance(tokenOwner, address(this));
        require(allowance >= amount, "RevCrowdsale: Check the token allowance");
        
        IERC20(_ssokuToken).transferFrom(tokenOwner, _accDestination, amount);
        
        uint256 finalValue = (amount / 1e18) * _rate;
    
        payable(tokenOwner).transfer(finalValue * 1 wei);

        _totalTokensBack += amount;
        
        return true;
    }    
}