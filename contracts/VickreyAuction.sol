pragma solidity ^0.5.16;

contract VickreyAuction{
  address seller;
  bool is_Open;
  uint256 Bidders_count;
  
  address[] bidders;
  //lowest acceptable bid
  uint256 public reserve_price;
  uint256 public timeout_bidding;
  uint256 public timeout_revealing;

  
  address public highBidder;
  uint256 public highBid_amount;
  uint256 public secondBid_amount;

  mapping(address => bool) public revealed;

  function Vickrey_Auction(uint256 _reserveprice, uint256 biddingPeriod, uint256 revealingPeriod) public {
    seller = msg.sender;
    Bidders_count = 0;
    reserve_price = _reserveprice;

    timeout_bidding = now + biddingPeriod;
    timeout_revealing = timeout_bidding + revealingPeriod;


    highBidder = seller;
    highBid_amount = reserve_price;
    secondBid_amount = reserve_price;

    revealed[seller] = true;

  }


  function getBidderscount() view private returns (uint) {
    return Bidders_count;
  }

  mapping(address => bytes32) public hashedBidOf;

  function bid(bytes32 hash) public{
    require(now < timeout_bidding,"Bidding Time is Completed");
    require(msg.sender!=seller,"You have to be a Bidder");

    hashedBidOf[msg.sender] = hash;
  }


  function reveal(uint256 price) public{
    require(now>=timeout_bidding && now < timeout_revealing,"Revealing time completed or revealing during Bidding");
    require(keccak256(abi.encodePacked(price)) == hashedBidOf[msg.sender],"Revealed bid not matches with the hash given");

    require(!revealed[msg.sender]);
    revealed[msg.sender] = true;

    if(price >= highBid_amount){
      secondBid_amount = highBid_amount;
      highBid_amount = price;
      highBidder = msg.sender;
    }
    else if (price > secondBid_amount){
      secondBid_amount = price;
    }

  }

  function getWinner_price() view public returns (address, uint256) {
      return (highBidder, secondBid_amount);
  }

}


