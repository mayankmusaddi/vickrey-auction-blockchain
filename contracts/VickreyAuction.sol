pragma solidity ^0.5.16;

contract VickreyAuction{
    address seller;
    
    uint public endOfBidding;
    uint public endOfRevealing;
    
    address public highBidder;
    uint public highBid;
    uint public secondBid;

    mapping(address => bool) public revealed;

    constructor(
      uint biddingPeriod,
      uint revealingPeriod
    ) 
    public 
    {
      endOfBidding = now + biddingPeriod;
      endOfRevealing = endOfBidding + revealingPeriod;
      seller = msg.sender;
      revealed[seller] = true;
    }

    mapping(address => bytes32) public hashedBidOf;

    function bid(uint amount, uint nonce) public{
      require(now < endOfBidding,"Bidding Time has Ended");
      require(msg.sender!=seller,"Seller cannot bid");
      bytes32 h = keccak256(abi.encodePacked(amount,nonce));
      hashedBidOf[msg.sender] = h;
    }


    function reveal(uint amount, uint nonce) public {
      require(now >= endOfBidding,"Revealing time has not begun");
      require(now < endOfRevealing,"Revealing time has Ended");

      require(keccak256(abi.encodePacked(amount, nonce)) == hashedBidOf[msg.sender], "Revealed Bid or Nonce don't match");

      require(!revealed[msg.sender], "Already Revealed");
      revealed[msg.sender] = true;

      if(amount >= highBid){
          secondBid = highBid;
          highBid = amount;
          highBidder = msg.sender;
      }
      else if (amount > secondBid){
          secondBid = amount;
      }
    }

    function getWinner() view public returns (address, uint) {
        return (highBidder, secondBid);
    }
}


