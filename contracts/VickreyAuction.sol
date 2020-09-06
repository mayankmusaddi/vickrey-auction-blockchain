pragma solidity ^0.5.16;

contract VickreyAuction{
  address seller;
  bool is_Open;
  uint Buyers_count;
  mapping (uint => address) buyers;
  uint[] offers;
  uint starting_price;

  modifier isopen() {
    require(is_Open == true);
    _;
  }

  function VickreyAuction(uint _starting) public {
    seller = msg.sender;
    isOpen = true;
    Buyers_count = 0;
    starting_price = _starting;
  }

  function getBuyerscount() view returns (uint) {
    return Buyers_count;
  }


  function bid(uint price, address buyer) isopen private{
    buyers[Buyers_count] = buyer;
    offers.push(price);
    Buyers_count++;
  }


  function getWinner() returns (address, uint) {

  }

}