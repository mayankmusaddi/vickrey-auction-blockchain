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

    function time() view public returns(string memory) {
        if(now < endOfBidding)
            return "Bidding";
        else if(now >= endOfBidding && now < endOfRevealing)
            return "Revealing";
        else
            return "Claim";
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