pragma solidity ^0.5.16;

contract BarbossaBrethren {
    address seller;

    uint public endOfBidding;
    uint public endOfRevealing;
    uint public sendBid;

    constructor(
        uint biddingPeriod,
        uint revealingPeriod
    )
        public
    {
        endOfBidding = now + biddingPeriod;
        endOfRevealing = endOfBidding + revealingPeriod;
        seller = msg.sender;
    }

    mapping(address => bytes32) public hashedBidOf;

    function bid(uint amount, uint nonce) public{
        require(now < endOfBidding);
        bytes32 h = keccak256(abi.encodePacked(amount,nonce));
        hashedBidOf[msg.sender] = h;
    }

    address public highBidder = msg.sender;
    uint public highBid;

    function reveal(uint amount, uint nonce) public {
        require(now >= endOfBidding && now < endOfRevealing);
        require(keccak256(abi.encodePacked(amount, nonce)) == hashedBidOf[msg.sender]);

        if (amount > highBid) {
            highBid = amount;
            highBidder = msg.sender;
        }
    }

    function claim() public {
        require(now >= endOfRevealing);
        sendBid = highBid;
    }
}