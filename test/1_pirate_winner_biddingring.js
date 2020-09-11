const BiddingRing = artifacts.require("BiddingRing");
const VickreyAuction = artifacts.require("VickreyAuction");
const { soliditySha3 } = require("web3-utils");

contract ("Vickrey Auction with highest bid from bidding ring\n", accounts => {
    it('should check that winner\'s address belongs to bidding ring and winning amount 0', async () => {
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
        var pbidAmount1 = 10; var pnonce1 = 20;
        const phashAmount1 = soliditySha3(pbidAmount1, pnonce1);
        console.log("pirate 1 address => ", pbidder1, "\n");

        // sending the hashed amount to bid function for pirates
        console.log("Pirates submitting the bids to bidding ring ...");
        biddingRing.bid(phashAmount1, {from : pbidder1});

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
        biddingRing.revealToVickrey({from:barbossaAddress});

        // getting the time left in revealing period
        var t2 = await vickreyAuction.timeLeftRevealing.call();
        await timeout((t2.toNumber()+1)*1000, "revealing", "Vickery Auction");

        var winner = await vickreyAuction.getWinner.call();
        console.log("Winner Address => ", winner[0]);
        console.log("Winning Amount => ", winner[1].toNumber());

        // paying the money to owner
        var sender = winner[0];
        if(winner[0] == biddingRing.address){
            sender = await biddingRing.getWinner.call();
        }
        let recvMoney = await vickreyAuction.sendBidValue.call({from : sender, value : winner[1].toNumber()});
        console.log(sender, " sent ", recvMoney.toNumber(), " money to the owner.");

        assert(winner[0] === biddingRing.address && winner[1].toNumber() == 0);

    });
});