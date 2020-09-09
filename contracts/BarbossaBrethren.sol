pragma solidity ^0.5.16;

/*
* A sealed bid auction conducted by the Barbossa's Brethren.
* Since it is implemented in a smart contract it has some differences
* from the traditional method. It also has a reveal time wherein
* every bidder would have to reveal their bids to acknowledge their claim.
*/

contract BarbossaBrethren {

    // State Variables
    address public seller;

    uint public endOfBidding;
    uint public endOfRevealing;

    address private highBidder;
    uint private highBid;

    // A constructor taking in the bidding time and revealing time as parameters
    constructor(
        uint _biddingPeriod,
        uint _revealingPeriod
    )
    public
    {
        endOfBidding = now + _biddingPeriod;
        endOfRevealing = endOfBidding + _revealingPeriod;
        seller = msg.sender;
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
    function timeLeftBidding() view public returns(uint) {
        return endOfBidding - now;
    }

    function timeLeftRevealing() view public returns(uint) {
        return endOfRevealing - now;
    }

    function time() view public returns(string memory) {
        if(now < endOfBidding)
            return "Bidding";
        else if(now >= endOfBidding && now < endOfRevealing)
            return "Revealing";
        else
            return "Claim";
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

    // Function to send the Barbossa's Brethren claim to the Vickrey Auction
    function toSend() view public returns (address, uint){
        require(now >= endOfRevealing, "Reveal period has not ended");
        return (highBidder, highBid);
    }
}