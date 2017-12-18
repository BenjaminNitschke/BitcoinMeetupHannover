pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract BtcGuesser is usingOraclize {
    function BtcGuesser() public {
        usdToReach = 10000;
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        state = "Initialized";
        // Every participant should send a small amount of ETH (5meth) to keep the contract alive and send out all funds to the winner
        //https://www.unixtimestamp.com/index.php
        guessers[0] = 0xb748f2D797a924B44888A6744C22b46F3fF3aCdB; //Benjamin
        guessersDay[0] = 1515628800; //2018-01-11
        guessers[1] = 0x1927D4294a560974f405246F4715f7fbE5d96196; //Another
        guessersDay[1] = 1513987200; //2017-12-23
        updatePrice(0); // first check at contract creation (mostly for testing)
    }
    uint usdToReach;
    string public state;
    //would be nicer via: mapping(address=>uint) guessersDay; but enumerating this is not easy: https://github.com/ethereum/dapp-bin/blob/master/library/iterable_mapping.sol
    address[2] guessers;
    uint[2] guessersDay;
    
    function getUsdToReach() public constant returns (uint) {
        return usdToReach;
    }
    
    uint public currentUsdPrice;
    
    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        currentUsdPrice = parseInt(result, 0);//cut off decimals, solidity only supports full numbers
        if (currentUsdPrice < usdToReach) {
            state = "Price not yet reached, will check again in 24h";
            updatePrice(60);//60*60*24); //60seconds*60minutes*24hours = once per day
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
            state = strConcat("Price reached, winner: ", uintToString(bestGuesserIndex));
            //https://ethereum.stackexchange.com/questions/31770/does-solidity-transfer-command-require-fee/31777
            guessers[bestGuesserIndex].transfer(this.balance);
            // Kill receiver address to make sure we can't use it again
            //causes invalid opcode: guessers[bestGuesserIndex] = 0;
            // And this stops the updating as we won't call updatePrice anymore (and we are out of eth)
        }
    }
    
    function updatePrice(uint delayInSeconds) payable {
        if (oraclize_getPrice("URL") > this.balance) {
            state = "Oraclize query was NOT sent, please add some ETH to cover for the query fee and call updatePrice again!";
        } else {
            //state = "Oraclize query was sent (delayed), standing by for the next answer";
            // Use https://jsonpath.curiousconcept.com/ to test json path
            oraclize_query(delayInSeconds, "URL", "json(https://api.coinmarketcap.com/v1/ticker/bitcoin/).[0].price_usd");
        }
    }
    
    // just for testing, should be 0 if payed out, if there is still a balance left it will be spend for the updatePrice and paid out if a date was reached!
    function getContractBalance() public constant returns (uint) {
        return this.balance;
    }
    
    //Utilities
    function strConcat(string _a, string _b) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ab = new string(_ba.length + _bb.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
        return string(bab);
    }
    function uintToString(uint v) internal pure returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }
}