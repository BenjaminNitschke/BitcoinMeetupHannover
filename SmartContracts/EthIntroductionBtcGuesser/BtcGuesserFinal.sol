pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract BtcGuesser is usingOraclize {
    function BtcGuesser() public {
        usdToReachMax = 25000;
		usdToReachMin = 12500;
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        state = "Initialized";
        // Every participant should send a small amount of ETH to keep the contract alive and send out all funds to the winner
		//Fund via: ethereum:0x1927D4294a560974f405246F4715f7fbE5d96196?amount=0.00748
		//Qr code: https://github.com/BenjaminNitschke/BitcoinMeetupHannover/tree/master/SmartContracts/EthIntroductionBtcGuesser/BitcoinMeetupSmartContractFundingAddress.png
		//Don't forget to email me about your guess day
        //https://www.unixtimestamp.com/index.php
        guessers[0] = 0xb748f2D797a924B44888A6744C22b46F3fF3aCdB; //Benjamin
        guessersDay[0] = 1518307200; //2018-02-11
        guessers[1] = 0x9b7338526b5f4fabe15401e4ade1622b0e2042c1; //Manuel
        guessersDay[1] = 1516406400; //2018-01-20
		guessers[2] = 0xcac4dbc944dfcf4904dab859408ffbf730947741; //Marco
        guessersDay[2] = 1516233600; //2018-01-18
		guessers[3] = 0x3bfc3f5832432f978c706d5f8f9e2f0db857300b; //unknown
		guessersDay[3] = 1516147200; //2018-01-17
		guessers[4] = 0x8Bdf2fB7AE659A975e22198cA6bAA4D66EF48511; //Thomas
		guessersDay[4] = 1522540800; //2018-04-01
		guessers[5] = 0x764A197e8d34B9c08ce26ed976F7f8694B670AF0; //Rafael
		guessersDay[5] = 1520035200; //2018-03-03
		guessers[6] = 0x3d88d28D2f81e350e6c2217d54d8eA0644a0023C; //Gerd
		guessersDay[6] = 1516060800; //2018-01-16
        updatePrice(0); // first check at contract creation (mostly for testing)
    }
    uint usdToReachMax;
	uint usdToReachMin;
    string public state;
    address[7] guessers;
    uint[7] guessersDay;
    uint public currentUsdPrice;
    
    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        currentUsdPrice = parseInt(result, 0);//cut off decimals, solidity only supports full numbers
        if (currentUsdPrice > usdToReachMin &&
			currentUsdPrice < usdToReachMax) {
            state = "Price not reached, next check in 24h";
            updatePrice(60*60*24); //60seconds*60minutes*24hours = once per day
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