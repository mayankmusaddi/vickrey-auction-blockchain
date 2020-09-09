const BarbossaBrethren = artifacts.require("BarbossaBrethren");
const VickreyAuction = artifacts.require("VickreyAuction");
const { soliditySha3 } = require("web3-utils");
const { assert } = require("console");

contract ("Linking barbossa and vickery", accounts => {
    it('should link the two', async () => {
        // deploying barbossaBrethren contract using address as accounts[0]
        var sellerAddress = accounts[9];
        var barbossaAddress = accounts[0];
        const vickreyAuction = await VickreyAuction.deployed({from:sellerAddress});
        const barbossaBrethren = await BarbossaBrethren.deployed({from : barbossaAddress});
        console.log("Vickrey Auction Address => ", vickreyAuction.address, "\n");
        console.log("Bidding Ring Address => ", barbossaBrethren.address, "\n");
        
        // barbossa calling the set address function
        var status = await barbossaBrethren.setAddress(vickreyAuction.address, {from : barbossaAddress});

        // declaring the pirate bidders and amounts
        var pbidder1 = accounts[1];
        var pbidAmount1 = 2; var pnonce1 = 20;
        var pbidder2 = accounts[2];
        var pbidAmount2 = 3; var pnonce2 = 3;
        const phashAmount1 = soliditySha3(pbidAmount1, pnonce1);
        const phashAmount2 = soliditySha3(pbidAmount2, pnonce2);
        console.log("pirate 1 address => ", pbidder1);
        console.log("pirate 2 address => ", pbidder2);
        console.log();

        // declaring the bidder address and amounts
        var bidder1 = accounts[8];
        var bidAmount1 = 1; var nonce1 = 2;
        var bidder2 = accounts[7];
        var bidAmount2 = 4; var nonce2 = 30;
        const hashAmount1 = soliditySha3(bidAmount1, nonce1);
        const hashAmount2 = soliditySha3(bidAmount2, nonce2);
        console.log("bidder 1 address => ", bidder1);
        console.log("bidder 2 address => ", bidder2);
        console.log();
        
        // sending the hashed amount to bid function for pirates
        console.log("Pirates submitting the bids to bidding ring ...");
        barbossaBrethren.bid(phashAmount1, {from : pbidder1});
        barbossaBrethren.bid(phashAmount2, {from : pbidder2});

        // sending the hashed amount to bid function for vickrey auction
        console.log("Bidders submitting the bids to Vickery Auction ...");
        vickreyAuction.bid(hashAmount1, {from : bidder1});
        vickreyAuction.bid(hashAmount2, {from : bidder2});

        // timeout function to wait till a period gets over.
        function timeout(ms, str1, str2) {
            console.log("Waiting for the " + str1 + " period to get over for " + str2 + " ....");
            return new Promise(resolve => setTimeout(resolve, ms));
        }
        
        // getting the time left in bidding period
        var t1 = await barbossaBrethren.timeLeftBidding.call();
        // console.log(t1.toNumber());
        await timeout(t1.toNumber()*1000, "bidding", "bidding ring");

        // revealing the bids for pirates
        console.log("Revealing the bids.");
        barbossaBrethren.reveal(pbidAmount2, pnonce2, {from : pbidder2});
        barbossaBrethren.reveal(pbidAmount1, pnonce1, {from : pbidder1});
        
        // getting the time left in revealing period
        var t2 = await barbossaBrethren.timeLeftRevealing.call();
        // console.log(t2.toNumber());
        await timeout(t2.toNumber()*1000, "revealing", "bidding ring");
        
        // var t3 = await barbossaBrethren.timeLeftRevealing();
        // console.log(t3.toNumber());
        // finding the winner
        // let winner = await barbossaBrethren.toSend.call();
        // var winner = await barbossaBrethren.highBidder.call();
        // console.log("winner address => ", winner[0]);
        // console.log("winning amount => ", winner[1].toNumber());

        barbossaBrethren.sendToVickery({from : barbossaAddress});
        // let stat = await barbossaBrethren.ended();
        // console.log(stat);
        // checking if the winner is bidder 2 or not
        // assert(winner[0] === bidder2 && winner[1].toNumber() === bidAmount2);


        
        // getting the time left in bidding period
        var t1 = await vickreyAuction.timeLeftBidding.call();
        // console.log(t1.toNumber());
        await timeout(t1.toNumber()*1000, "bidding", "Vickery Auction");

        // Revealing bids for Vickery Auction
        console.log("Revealing bids for Vickery Auction");
        vickreyAuction.reveal(bidAmount2, nonce2, {from : bidder2});
        vickreyAuction.reveal(bidAmount1, nonce1, {from : bidder1});
        barbossaBrethren.revealToVickery({from:barbossaAddress});

        // getting the time left in revealing period
        var t2 = await vickreyAuction.timeLeftRevealing.call();
        // console.log(t2.toNumber());
        await timeout(t2.toNumber()*1000, "revealing", "Vickery Auction");

        var winner = await vickreyAuction.getWinner.call();
        console.log("Winner Address => ", winner[0]);
        console.log("Winning Amount => ", winner[1].toNumber());

        assert(winner[0] === bidder2);
        // assert(winner[0] === barbossaBrethren.address);

    });
});