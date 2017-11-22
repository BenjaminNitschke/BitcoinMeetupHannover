pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract BtcGuesser is usingOraclize {
    function BtcGuesser() public {
        usdToReach = 10000;
        state = "Initialized";
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        updatePrice(0); // first check at contract creation
        // Every participant should send a small amount of ETH (5meth) to keep the contract alive and send out all funds to the winner
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
    
    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        currentUsdPrice = parseInt(result, 0);//cut off decimals, solidity only supports full numbers
        if (currentUsdPrice < usdToReach) {
            updatePrice(60); //60*60*24 = once per day
        }
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
            // We have a winner, transfer all funds to him (whatever is left in this contract)
            state = "Price reached, winner was payed out";
            guessers[bestGuesserIndex].transfer(this.balance);
            // And this stops the updating
        }
    }
    
    function updatePrice(uint delayInSeconds) payable {
        if (oraclize_getPrice("URL") > this.balance) {
            state = "Oraclize query was NOT sent, please add some ETH to cover for the query fee";
        } else {
            //state = "Oraclize query was sent (delayed), standing by for the next answer";
            // Use https://jsonpath.curiousconcept.com/ to test json path
            oraclize_query(delayInSeconds, "URL", "json(https://api.coinmarketcap.com/v1/ticker/bitcoin/).[0].price_usd");
            state = "Price not yet reached, will check again in 24h";
        }
    }
    
    address[2] guessers;
    uint[2] guessersDay;
}