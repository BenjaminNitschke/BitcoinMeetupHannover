pragma solidity ^0.4.0;
import "./Utilities.sol";

contract BtcGuesser is Utilities {
    function BtcGuesser() public {
        usdToReach = 10000;
        state = "Initialized";
        updatePrice(); // first check at contract creation
    }
    uint usdToReach;
    string public state;
    
    function getUsdToReach() public constant returns (uint) {
        return usdToReach;
    }
    
    uint public currentUsdPrice;
    
    function updatePrice() public payable {
        //string result = "7984.58";
        //parseInt(result, 2);
        if (currentUsdPrice == 0)
            currentUsdPrice = 7984;
        else
            currentUsdPrice += 137;
        state = strConcat("Price updated: ", uintToString(now));
    }
}