pragma solidity ^0.4.0;
import "./Utilities.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract BtcGuesser is Utilities {
    using strings for *;
    function BtcGuesser() public {
        usdToReach = 10000;
        state = "Initialized";
        updatePrice(); // first check at contract creation
        //https://www.unixtimestamp.com/index.php
        guessers[0] = 0xb748f2D797a924B44888A6744C22b46F3fF3aCdB; //Benjamin
        guessersDay[0] = 1515628800; //2018-01-11
        guessers[1] = 0x1927D4294a560974f405246F4715f7fbE5d96196; //Another
        guessersDay[1] = 1513987200; //2017-12-23
    }
    uint usdToReach;
    string public state;
    
    function getUsdToReach() public constant returns (uint) {
        return usdToReach;
    }
    
    uint public currentUsdPrice;
    
    function updatePrice() public payable {
        if (state.toSlice().startsWith("Price reached".toSlice()))
            return;
        if (currentUsdPrice == 0)
            currentUsdPrice = 8284;
        else
            currentUsdPrice += 537;
        if (currentUsdPrice < usdToReach)
            state = strConcat("Price updated, not yet reached: ", uintToString(now));
        else {
            // Target price reached, go through guessers and stop when we reach date
            uint bestGuesserIndex = 0;
            uint bestGuesserDayDifference = 10000000;
            for (uint index=0; index<guessers.length; index++) {
                if (guessersDay[index] - now < bestGuesserDayDifference) {
                    bestGuesserIndex = index;
                    bestGuesserDayDifference = guessersDay[index] - now;
                }
            }
            // We have a winner, transfer all funds to him
            state = strConcat("Price reached, winner: ", uintToString(bestGuesserIndex));
            guessers[bestGuesserIndex].transfer(this.balance);
        }
    }
    
    address[2] guessers;
    uint[2] guessersDay;
}