// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

/*
* A Base Auction contract from which both the Vickrey Auction and Bidding Ring contracts
* would be inherited. We have made a separate contract because most of the part of the code
* was same including most of the bid and reveal functions and the modifiers.
*/

contract BaseAuction{

    // State Variables
    address payable internal owner;

    uint internal endOfBidding;
    uint internal endOfRevealing;

    address internal highBidder;
    uint internal highBid;
    bool internal sendTime;

    // A revealed mapping which disallows seller to bid
    mapping(address => bool) internal revealed;

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }
    modifier withinBidTime {
      require(block.timestamp < endOfBidding, "Bidding Time has Ended");
      _;
    }
    modifier withinRevealTime {
      require(block.timestamp >= endOfBidding,"Revealing time has not begun");
      require(block.timestamp < endOfRevealing,"Revealing time has Ended");
      _;
    }

    // The bids are stored in a hashed format so that it is not visible even to the seller
    mapping(address => bytes32) internal hashedBidOf;

    // A bidding function where one needs to send the hashed value of their bidding amount
    // This could be done using web3.utils.keccak256(uint amount, uint nonce)
    // Here nonce is a random value that needs to remembered by the bidder till the reveal time
    // This is done so as to make the hashes of two different bids completely indistinguishable
    function bid(bytes32 h) public withinBidTime {
      hashedBidOf[msg.sender] = h;
    }
    
    // Helper functions to indicate the current time and the time left for different periods
    function timeLeftBidding() public withinBidTime returns(uint) {
      sendTime = true;
      return endOfBidding - block.timestamp;
    }

    function timeLeftRevealing() public withinRevealTime returns(uint) {
      sendTime = true;
      return endOfRevealing - block.timestamp;
    }

    // During the revealing time this function needs to be called to levy the claim
    function reveal(uint amount, uint nonce) public withinRevealTime {
      require(keccak256(abi.encodePacked(amount, nonce)) == hashedBidOf[msg.sender], "Revealed Bid or Nonce don't match");
      require(!revealed[msg.sender], "Bid Already Revealed");
      revealed[msg.sender] = true;
    }
}