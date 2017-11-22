pragma solidity ^0.4.0;

contract BtcGuesser {
    function BtcGuesser() public {
        usdToReach = 10000;
    }
    uint usdToReach;
    
    function getUsdToReach() public constant returns (uint) {
        return usdToReach;
    }
    
    uint public currentUsdPrice;
    
    function setCurrentUsdPrice(uint newUsdPrice) public payable {
        currentUsdPrice = newUsdPrice;
    }
}