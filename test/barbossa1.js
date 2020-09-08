const BarbossaBrethren = artifacts.require("BarbossaBrethren");
const { soliditySha3 } = require("web3-utils");
const { assert } = require("console");

contract ("BarbossaBrethren", accounts => {
    it('should check winner is bidder2', async () => {
        // deploying barbossaBrethren contract using address as accounts[0]
        var barbossaAddress = accounts[0];
        const barbossaBrethren = await BarbossaBrethren.deployed({from : barbossaAddress});
        
        // declaring the bidder address and amounts
        var bidder1 = accounts[1];
        var bidAmount1 = 100;
        var bidder2 = accounts[2];
        var bidAmount2 = 200;
        const hashAmount1 = soliditySha3(bidAmount1);
        const hashAmount2 = soliditySha3(bidAmount2);
        console.log("bidder 1 address => ", bidder1);
        console.log("bidder 2 address => ", bidder2);
        console.log();

        // sending the hashed amount to bid function
        console.log("Submitting the bids.");
        barbossaBrethren.bid(hashAmount1, {from : bidder1});
        barbossaBrethren.bid(hashAmount2, {from : bidder2});

        // timeout function to wait till a period gets over.
        function timeout(ms, str) {
            console.log("Waiting for " + str + " period to get over ....");
            return new Promise(resolve => setTimeout(resolve, ms));
        }
        
        // getting the time left in bidding period
        var t1 = await barbossaBrethren.timeLeftBidding.call();
        await timeout(t1.toNumber()*1000, "bidding");

        // revealing the bids
        console.log("Revealing the bids.");
        barbossaBrethren.reveal(bidAmount2, {from : bidder2});
        barbossaBrethren.reveal(bidAmount1, {from : bidder1});
        
        // getting the time left in revealing period
        var t2 = await barbossaBrethren.timeLeftRevealing.call();
        await timeout(t2.toNumber()*1000, "revealing");
        
        // finding the winner
        var winner = await barbossaBrethren.highBidder.call();
        console.log("winner address => ", winner);
        
        // checking if the winner is bidder 2 or not
        assert(winner === bidder2);
    });
});