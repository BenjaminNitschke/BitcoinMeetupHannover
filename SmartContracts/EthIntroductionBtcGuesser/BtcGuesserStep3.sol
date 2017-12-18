pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

// Based on https://github.com/oraclize/ethereum-examples/blob/master/solidity/KrakenPriceTicker.sol
// Must be tested at https://dapps.oraclize.it/browser-solidity/
contract BtcGuesser is usingOraclize {
    function BtcGuesser() public {
        state = "Initialized";
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        updatePrice(0);
    }
    uint public btcUsd;
    string public state;
    
    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        btcUsd = parseInt(result, 0);//cut off decimals, solidity only supports full numbers
        updatePrice(60); //60*60*24 = once per day
    }

    function updatePrice(uint delayInSeconds) payable {
        if (oraclize_getPrice("URL") > this.balance) {
            state = "Oraclize query was NOT sent, please add some ETH to cover for the query fee and call updatePrice again!";
        } else {
            state = "Oraclize query was sent (delayed), standing by for the next answer";
            // Use https://jsonpath.curiousconcept.com/ to test json path
            oraclize_query(delayInSeconds, "URL", "json(https://api.coinmarketcap.com/v1/ticker/bitcoin/).[0].price_usd");
        }
    }
}