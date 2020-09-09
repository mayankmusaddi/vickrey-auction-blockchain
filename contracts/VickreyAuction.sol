pragma solidity ^0.5.16;

/*
* A Vickrey sealed bid auction had been implemented in the following contract
* Here the highest bidder wins but has to pay only the second highest bid
* Since it is implemented in a smart contract it has some differences
* from the traditional method. It also has a reveal time wherein
* every bidder would have to reveal their bids to acknowledge their claim.
*/

contract VickreyAuction{

    // State Variables
    address seller;

    uint public endOfBidding;
    uint public endOfRevealing;
    
    address private highBidder;
    uint private highBid;
    uint private secondBid;

    // A revealed mapping which disallows seller to bid
    mapping(address => bool) private revealed;

    // A constructor taking in the bidding time and revealing time as parameters
    constructor (
      uint _biddingPeriod,
      uint _revealingPeriod
    ) 
    public
    {
      endOfBidding = now + _biddingPeriod;
      endOfRevealing = endOfBidding + _revealingPeriod;
      seller = msg.sender;
      revealed[seller] = true;
    }

    // The bids are stored in a hashed format so that it is not visible even to the seller
    mapping(address => bytes32) private hashedBidOf;

    // A bidding function where one needs to send the hashed value of their bidding amount
    // This could be done using web3.utils.keccak256(uint amount, uint nonce)
    // Here nonce is a random value that needs to remembered by the bidder till the reveal time
    // This is done so as to make the hashes of two different bids completely indistinguishable
    function bid(bytes32 h) public {
      require(now < endOfBidding, "Bidding Time has Ended");
      require(msg.sender!=seller, "Seller cannot bid");
    //   bytes32 h = keccak256(abi.encodePacked(amount,nonce));
      hashedBidOf[msg.sender] = h;
    }
    bool private sendTime = false;
    // Helper functions to indicate the current time and the time left for different periods
    function timeLeftBidding() public returns(uint) {
      require(now < endOfBidding, "Bidding Time has Ended");
      sendTime = true;
      return endOfBidding - now;
    }

    function timeLeftRevealing() public returns(uint) {
      require(now >= endOfBidding,"Revealing time has not begun");
      require(now < endOfRevealing,"Revealing time has Ended");
      sendTime = true;
      return endOfRevealing - now;
    }

    // During the revealing time this function needs to be called to levy the claim
    function reveal(uint amount, uint nonce) public {
      require(now >= endOfBidding,"Revealing time has not begun");
      require(now < endOfRevealing,"Revealing time has Ended");

      require(keccak256(abi.encodePacked(amount, nonce)) == hashedBidOf[msg.sender], "Revealed Bid or Nonce don't match");

      require(!revealed[msg.sender], "Already Revealed");
      revealed[msg.sender] = true;

      // private variables store the highest bid, the second highest bid and the bidder during reveal time
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