const BiddingRing = artifacts.require("BiddingRing");

module.exports = function (deployer) {
  deployer.deploy(BiddingRing);
};
