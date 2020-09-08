pragma solidity ^0.5.16;

contract BarbossaBrethren {
    address seller;

    uint public endOfBidding;
    uint public endOfRevealing;

    address public highBidder;
    uint public highBid;

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
        require(now < endOfBidding,"Bidding Time has Ended");
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

    function reveal(uint amount, uint nonce) public {
        require(now >= endOfBidding,"Revealing time has not begun");
        require(now < endOfRevealing,"Revealing time has Ended");

        require(keccak256(abi.encodePacked(amount, nonce)) == hashedBidOf[msg.sender], "Revealed Bid or Nonce don't match");

        if (amount > highBid) {
            highBid = amount;
            highBidder = msg.sender;
        }
    }

    function toSend() public returns (address,uint){
        require(now >= endOfRevealing, "Reveal period has not ended");
        return (seller,highBid);
    }
}