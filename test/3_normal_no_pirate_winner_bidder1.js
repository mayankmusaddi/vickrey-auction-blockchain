const VickreyAuction = artifacts.require("VickreyAuction");
const { soliditySha3 } = require("web3-utils");

contract ("Vickrey Auction with no pirates\n", accounts => {
    it('Winner should be the bidder 3 and amount 3', async () => {
        // deploying biddingRing contract using address as accounts[0]
        var sellerAddress = accounts[9];
        var barbossaAddress = accounts[0];
        const vickreyAuction = await VickreyAuction.deployed({from:sellerAddress});
        console.log("Vickrey Auction Address => ", vickreyAuction.address);
        
        // declaring the bidder address and amounts
        var bidder1 = accounts[8];
        var bidAmount1 = 1; var nonce1 = 2;
        var bidder2 = accounts[7];
        var bidAmount2 = 3; var nonce2 = 30;
        var bidder3 = accounts[6];
        var bidAmount3 = 5; var nonce3 = 13;
        const hashAmount1 = soliditySha3(bidAmount1, nonce1);
        const hashAmount2 = soliditySha3(bidAmount2, nonce2);
        const hashAmount3 = soliditySha3(bidAmount3, nonce3);
        console.log("bidder 1 address => ", bidder1);
        console.log("bidder 2 address => ", bidder2);
        console.log("bidder 3 address => ", bidder3, "\n");
        
        // sending the hashed amount to bid function for vickrey auction
        console.log("Bidders submitting the bids to Vickery Auction ...");
        vickreyAuction.bid(hashAmount1, {from : bidder1});
        vickreyAuction.bid(hashAmount2, {from : bidder2});
        vickreyAuction.bid(hashAmount3, {from : bidder3});

        // timeout function to wait till a period gets over.
        function timeout(ms, str1, str2) {
            console.log("Waiting for the " + str1 + " period to get over for " + str2 + " ....");
            return new Promise(resolve => setTimeout(resolve, ms));
        }
        
        // getting the time left in bidding period
        var t1 = await vickreyAuction.timeLeftBidding.call();
        await timeout((t1.toNumber()+1)*1000, "bidding", "Vickery Auction");

        // Revealing bids for Vickery Auction
        console.log("Revealing bids for Vickery Auction");
        vickreyAuction.reveal(bidAmount2, nonce2, {from : bidder2});
        vickreyAuction.reveal(bidAmount1, nonce1, {from : bidder1});
        vickreyAuction.reveal(bidAmount3, nonce3, {from : bidder3});

        // getting the time left in revealing period
        var t2 = await vickreyAuction.timeLeftRevealing.call();
        await timeout((t2.toNumber()+1)*1000, "revealing", "Vickery Auction");

        var winner = await vickreyAuction.getWinner.call();
        console.log("Winner Address => ", winner[0]);
        console.log("Winning Amount => ", winner[1].toNumber());

        // paying the money to owner
        var sender = winner[0];
        let recvMoney = await vickreyAuction.sendBidValue.call({from : sender, value : winner[1].toNumber()});
        console.log(sender, " sent ", recvMoney.toNumber(), " money to the owner.");

        assert(winner[0] === bidder3 && winner[1].toNumber() === bidAmount2);

    });
});