// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./BaseAuction.sol";

/*
* A Vickrey sealed bid auction had been implemented in the following contract
* Here the highest bidder wins but has to pay only the second highest bid
* Since it is implemented in a smart contract it has some differences
* from the traditional method. It also has a reveal time wherein
* every bidder would have to reveal their bids to ackblock.timestampledge their claim.
*/

contract VickreyAuction is BaseAuction {

    // State Variables
    uint private secondBid;

    // A constructor taking in the bidding time and revealing time as parameters
    constructor (uint _biddingPeriod, uint _revealingPeriod) public {
      endOfBidding = block.timestamp + _biddingPeriod;
      endOfRevealing = endOfBidding + _revealingPeriod;
      owner = msg.sender;
      revealed[owner] = true;
      highBid = 0;
      secondBid = 0;
    }

    // Overriden the bid function of BaseAuction Contract
    function bid(bytes32 h) public {
      require(msg.sender != owner, "Seller cannot bid");
      BaseAuction.bid(h);
    }

    // Overridden the reveal function of BaseAuction Contract
    function reveal(uint amount, uint nonce) public {
      BaseAuction.reveal(amount, nonce);
      if(amount >= highBid){
          secondBid = highBid;
          highBid = amount;
          highBidder = msg.sender;
      }
      else if (amount > secondBid){
          secondBid = amount;
      }
    }

    // Function to finally declare the winner of the Auction along with the amount they have to pay
    // This is in assumption that the bidder will rightfully pay and hence amounts are not collected during bidding
    function getWinner() view public returns (address, uint) {
        return (highBidder, secondBid);
    }
}