pragma solidity ^0.5.16;

contract BarbossaBrethren {
    address seller;

    uint public initPrice;
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

    mapping(address => uint) public hashedBidOf;

    function encode(uint amount, uint nonce) pure public returns(uint){
        return uint(keccak256(abi.encodePacked(amount,nonce)));
    }

    function bid(uint hash) public{
        // require(now < endOfBidding);
        hashedBidOf[msg.sender] = hash;
    }

    address public highBidder = msg.sender;
    uint public highBid;

    function reveal(uint amount, uint nonce) public {
        require(now >= endOfBidding && now < endOfRevealing);
        require(uint(keccak256(abi.encodePacked(amount, nonce))) == hashedBidOf[msg.sender]);

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