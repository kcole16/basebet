/*
   Uses official MLB API to track scores

   This contract keeps in storage an updated game winner,
   which is updated every ~60 seconds.
*/

pragma solidity ^0.4.4;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract MLBGameWinner is usingOraclize {
    
    string public winner;

    mapping (bytes32 => bet) bets;

    struct Bet {
        bytes32 gameId;
        bytes32 winner;
    }

    struct Users {
        string handle;
        bytes32[] bets;
    }

    bytes32[] betsByNotaryHash;
    bytes32[] userByAddress;

    event newOraclizeQuery(string description);
    event newMLBGameWinner(string winner);
    
    //Add entire contract here
    //Call contract with preset url (passed as argument)
    //All choosing logic is done in JS

    function MLBGameScore() {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        update();
    }

    function registerNewUser(string handle) returns (bool success) {
        address thisNewAddress = msg.sender;
        // don't overwrite existing entries, and make sure handle isn't null
        if (bytes(Users[msg.sender].handle).length == 0 && bytes(handle).length != 0) {
          Users[thisNewAddress].handle = handle;
          usersByAddress.push(thisNewAddress);  // adds an entry for this user to the user 'whitepages'
          return true;
        } else {
          return false; // either handle was null, or a user with this handle already existed
        }
    }

    function registerNewBet(bytes32 gameId, bytes32 selectedWinner, bytes32 SHA256notaryHash, int betAmount) returns (bool success) {
        address thisNewAddress = msg.sender;
        if (bytes(Users[thisNewAddress].handle).length != 0) {
            if (bytes(gameId).length != 0 && bytes(selectedWinner).length != 0) {
                if (bytes(Users[thisNewAddress][bets][SHA256notaryHash]).length == 0) {
                    Users[thisNewAddress][bets].push(SHA256notaryHash);
                    bets[SHA256notaryHash].gameId = gameId;
                    bets[SHA256notaryHash].selectedWinner = selectedWinner;
                    bets[SHA256notaryHash].timestamp = block.timestamp;
                    bets[SHA256notaryHash].betAmount = betAmount;
                }
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    function __callback(bytes32 myid, string result, bytes proof, bytes32 SHA256notaryHash) {
        if (msg.sender != oraclize_cbAddress()) throw;
        winner = result;
        selectedWinner = bets[SHA256notaryHash].selectedWinner;
        newMLBGameWinner(winner);
        if (winner == selectedWinner) {
            //pay
        } else {
            //don't pay
        }
    }
    
    function update() payable {
        if (oraclize.getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            //URL should be from msg
            //"json(http://a9231544.ngrok.io/final_scores/?month=06&day=05).scores.490957.winner"
            oraclize_query(scheduled_arrivaltime+24*3600, "URL", msg.url);
        }
    }
    
} 