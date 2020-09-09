const BiddingRing = artifacts.require("BiddingRing");
const VickreyAuction = artifacts.require("VickreyAuction");
const { soliditySha3 } = require("web3-utils");

contract ("Vickrey Auction with highest bid from bidding ring\n", accounts => {
    it('should check that winner\'s address belongs to bidder 2 and winning amount 4', async () => {
        // deploying biddingRing contract using address as accounts[0]
        var sellerAddress = accounts[9];
        var barbossaAddress = accounts[0];
        const vickreyAuction = await VickreyAuction.deployed({from:sellerAddress});
        const biddingRing = await BiddingRing.deployed({from : barbossaAddress});
        console.log("\n", "Vickrey Auction Address => ", vickreyAuction.address);
        console.log("Bidding Ring Address => ", biddingRing.address, "\n");
        
        // barbossa calling the set address function
        var status = await biddingRing.setAddress(vickreyAuction.address, {from : barbossaAddress});

        // declaring the pirate bidders and amounts
        var pbidder1 = accounts[1];
        var pbidAmount1 = 1; var pnonce1 = 20;
        var pbidder2 = accounts[2];
        var pbidAmount2 = 2; var pnonce2 = 3;
        var pbidder3 = accounts[3];
        var pbidAmount3 = 4; var pnonce3 = 420;
        const phashAmount1 = soliditySha3(pbidAmount1, pnonce1);
        const phashAmount2 = soliditySha3(pbidAmount2, pnonce2);
        const phashAmount3 = soliditySha3(pbidAmount3, pnonce3);
        console.log("pirate 1 address => ", pbidder1);
        console.log("pirate 2 address => ", pbidder2);
        console.log("pirate 3 address => ", pbidder3, "\n");

        // declaring the bidder address and amounts
        var bidder1 = accounts[8];
        var bidAmount1 = 1; var nonce1 = 69;
        var bidder2 = accounts[7];
        var bidAmount2 = 5; var nonce2 = 30;
        const hashAmount1 = soliditySha3(bidAmount1, nonce1);
        const hashAmount2 = soliditySha3(bidAmount2, nonce2);
        console.log("bidder 1 address => ", bidder1);
        console.log("bidder 2 address => ", bidder2, "\n");
        
        // sending the hashed amount to bid function for pirates
        console.log("Pirates submitting the bids to bidding ring ...");
        biddingRing.bid(phashAmount1, {from : pbidder1});
        biddingRing.bid(phashAmount2, {from : pbidder2});
        biddingRing.bid(phashAmount3, {from : pbidder3});

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
        var t1 = await biddingRing.timeLeftBidding.call();
        await timeout(t1.toNumber()*1000, "bidding", "bidding ring");

        // revealing the bids for pirates
        console.log("Revealing the bids.");
        biddingRing.reveal(pbidAmount2, pnonce2, {from : pbidder2});
        biddingRing.reveal(pbidAmount3, pnonce3, {from : pbidder3});
        biddingRing.reveal(pbidAmount1, pnonce1, {from : pbidder1});
        
        // getting the time left in revealing period
        var t2 = await biddingRing.timeLeftRevealing.call();
        await timeout(t2.toNumber()*1000, "revealing", "bidding ring");
        
        biddingRing.sendToVickrey({from : barbossaAddress});
        
        // getting the time left in bidding period
        var t1 = await vickreyAuction.timeLeftBidding.call();
        await timeout((t1.toNumber()+1)*1000, "bidding", "Vickery Auction");

        // Revealing bids for Vickery Auction
        console.log("Revealing bids for Vickery Auction");
        vickreyAuction.reveal(bidAmount2, nonce2, {from : bidder2});
        vickreyAuction.reveal(bidAmount1, nonce1, {from : bidder1});
        biddingRing.revealToVickrey({from:barbossaAddress});

        // getting the time left in revealing period
        var t2 = await vickreyAuction.timeLeftRevealing.call();
        await timeout((t2.toNumber()+1)*1000, "revealing", "Vickery Auction");

        var winner = await vickreyAuction.getWinner.call();
        console.log("Winner Address => ", winner[0]);
        console.log("Winning Amount => ", winner[1].toNumber());

        assert(winner[0] === bidder2 && winner[1].toNumber() == pbidAmount3);

    });
});