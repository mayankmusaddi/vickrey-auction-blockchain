pragma solidity ^0.5.16;

contract BarbossaBrethren {
    address public seller;

    uint public biddingPeriod;
    uint public endOfBidding;
    uint public endOfRevealing;

    address public highBidder;
    uint public highBid;

    constructor(
        uint _biddingPeriod,
        uint _revealingPeriod
    )
        public
    {
        biddingPeriod = _biddingPeriod;
        endOfBidding = now + _biddingPeriod;
        endOfRevealing = endOfBidding + _revealingPeriod;
        seller = msg.sender;
    }

    mapping(address => bytes32) public hashedBidOf;

    function bid(bytes32 h) public {
        require(now < endOfBidding);
        hashedBidOf[msg.sender] = h;
    }

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

    address public highBidder = msg.sender;
    uint public highBid;

    function reveal(uint amount) public {
        require(now >= endOfBidding && now < endOfRevealing);
        require(keccak256(abi.encodePacked(amount)) == hashedBidOf[msg.sender]);

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