const VickreyAuction = artifacts.require("VickreyAuction");

module.exports = function (deployer) {
  deployer.deploy(VickreyAuction);
};
