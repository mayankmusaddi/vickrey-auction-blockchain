pragma solidity ^0.5.16;

import "./BaseAuction.sol";
import "./VickreyAuction.sol";

/*
* A sealed bid auction conducted by the Barbossa's Brethren.
* Since it is implemented in a smart contract it has some differences
* from the traditional method. It also has a reveal time wherein
* every bidder would have to reveal their bids to acknowledge their claim.
*/

contract BiddingRing is BaseAuction{

    // State Variables
    VickreyAuction vk;
    uint private myNonce;
    bool public sent;
    bool public revealed;

    // A constructor taking in the bidding time and revealing time as parameters
    constructor() public {
        owner = msg.sender;
        myNonce = 10;
        highBid = 0;
    }

    // function to set address of main auction
    function setAddress(address _t) public onlyOwner {
        vk = VickreyAuction(_t);
        uint tm = vk.timeLeftBidding();
        endOfBidding = now + tm - 4;
        endOfRevealing = endOfBidding + 2;
    }

    // During the revealing time this function needs to be called to levy the claim
    function reveal(uint amount, uint nonce) public {
        BaseAuction.reveal(amount, nonce);
        if (amount > highBid) {
            highBid = amount;
            highBidder = msg.sender;
        }
    }

    // Function to send bid from bidding ring to the Vickrey Auction
    function sendToVickrey() public onlyOwner {
        vk.bid(keccak256(abi.encodePacked(highBid, myNonce)));
        sent = true;
    }

    // Function to reveal bid to vickery
    function revealToVickrey() public onlyOwner {
        vk.reveal(highBid, myNonce);
        revealed = true;
    }
}