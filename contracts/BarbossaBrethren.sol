pragma solidity ^0.5.16;

import "./VickreyAuction.sol";

/*
* A sealed bid auction conducted by the Barbossa's Brethren.
* Since it is implemented in a smart contract it has some differences
* from the traditional method. It also has a reveal time wherein
* every bidder would have to reveal their bids to acknowledge their claim.
*/

contract BarbossaBrethren {

    // State Variables
    address public seller;
    VickreyAuction vk;
    uint private endOfBidding;
    uint private endOfRevealing;

    address private highBidder;
    uint private highBid;
    uint private myNonce;
    bool public sent;
    bool public revealed;
    bool sendTime;

    // A constructor taking in the bidding time and revealing time as parameters
    constructor() public {
        seller = msg.sender;
        myNonce = 10;
        highBid = 0;
    }

    // function to set address of main auction
    function setAddress(address _t) public {
        require(msg.sender == seller);
        vk = VickreyAuction(_t);
        uint tm = vk.timeLeftBidding();
        endOfBidding = now + tm - 4;
        endOfRevealing = endOfBidding + 2;
    }

    // The bids are stored in a hashed format so that it is not visible even to the seller
    mapping(address => bytes32) private hashedBidOf;

    // A bidding function where one needs to send the hashed value of their bidding amount
    // This could be done using web3.utils.keccak256(uint amount, uint nonce)
    // Here nonce is a random value that needs to remembered by the bidder till the reveal time
    // This is done so as to make the hashes of two different bids completely indistinguishable
    function bid(bytes32 h) public {
        require(now < endOfBidding,"Bidding Time has Ended");
        hashedBidOf[msg.sender] = h;
    }

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

        // private variables store the highest bid and the bidder during reveal time
        if (amount > highBid) {
            highBid = amount;
            highBidder = msg.sender;
        }
    }

    // Function to send bid from bidding ring to the Vickrey Auction
    function sendToVickery() public {
        require(now >= endOfRevealing, "Reveal period has not ended");
        require(msg.sender == seller);
        vk.bid(keccak256(abi.encodePacked(highBid, myNonce)));
        sent = true;
    }
    // Function to reveal bid to vickery
    function revealToVickery() public {
        require(now >= endOfRevealing, "Reveal period has not ended");
        require(msg.sender == seller && sent == true);
        // require(sent == true);
        vk.reveal(highBid, myNonce);
        revealed = true;
    }

}