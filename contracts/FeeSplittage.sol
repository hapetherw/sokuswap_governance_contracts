// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract FeeSplittage {

    address admin;
    uint fee;
    
    uint totalFeeRate = 25;
    uint liquidityProvidersShare = 100 * 17 / totalFeeRate;
    uint stakingShare = 100 * 5 / totalFeeRate;
    uint treasureShare = 100 * 2 / totalFeeRate;
    uint rewardsShare = 100 * 1 / totalFeeRate;

    address payable private _liquidityProvidersAddr;
    address payable private _stakingAddr;
    address payable private _treasureAddr;
    address payable private _rewardsAddr;

    constructor(address payable liquidityProvidersAddr, address payable stakingAddr, address payable treasureAddr, address payable rewardsAddr) {

        _liquidityProvidersAddr = liquidityProvidersAddr;
        _stakingAddr = stakingAddr;
        _treasureAddr = treasureAddr;
        _rewardsAddr = rewardsAddr;
    
        admin = msg.sender;
    }

    //function splitFunds() public payable {
        function splitFunds() public payable {

        uint totalFeeValue = msg.value;
        
        uint _liquidityProvidersValue = ((totalFeeValue * liquidityProvidersShare) / 100);
        uint _stakingAddrValue = ((totalFeeValue * stakingShare) / 100);
        uint _treasureAddrValue = ((totalFeeValue * treasureShare) / 100);
        uint _rewardsAddrValue = ((totalFeeValue * rewardsShare) / 100);
        
        _liquidityProvidersAddr.transfer(_liquidityProvidersValue);
        _stakingAddr.transfer(_stakingAddrValue);
        _treasureAddr.transfer(_treasureAddrValue);
        _rewardsAddr.transfer(_rewardsAddrValue);
        
        uint remainValue = totalFeeValue - (_liquidityProvidersValue + _stakingAddrValue + _treasureAddrValue + _rewardsAddrValue);
        
        if(remainValue > 0) {
            _treasureAddr.transfer(remainValue);
        }
    }
}