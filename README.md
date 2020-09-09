# Vickrey Auction

* Using Solidity we implemented the **vickrey auction** and **bidding ring** smart contracts where one can bid in the *bidding period* with the *hashed amount* and reveal in the *revealing period* and 
* **Security** is ensured in the smart contract because of sending the hash value of the amount during bidding time by the bidders.
* **Visibility** which is to secure certain parts(functions) of the smart contracts  and **Modifiers** which allows the control of the smart contract functions were implemented.
* **Doxygen Comments** were written in the solidity files for readability of the code.
* **Tests** were implemented to check the working of smartcontracts properly or not
* We mentioned the time for bidding period and revealing period in **./migrations/2_vickreyauction_deploy.js**


## Solidity Files

### BaseAuction
* It's a smart contract where the VickreyAuction and BiddingRing smart contracts will inheret which consists of modifiers, bid and reveal functions
### VickreyAuction
* It's a smart contract where we know the calculate the winner of the auction.
### BiddingRing
* It's a smart contract where we 

## Tests
We have implemented the tests in **.js** files in **./test** folder to check the smart contracts that we have written 
### Test1
* To check the winner of auction is from the bidding ring.
### Test2
* To check the winner of auction when 2 normal individuals and 2 pirates have participated with the max amount bidded by them is same.
### Test3
* To check the winner of auction when 2 normal individuals and 2 pirates have participated.
### Test4
* To check the winner of auction when 2 normal individuals and 3 pirates have participated.
### Test5 
* To check the winner of auction when there were no pirates.
