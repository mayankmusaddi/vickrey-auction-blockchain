const VickreyAuction = artifacts.require("VickreyAuction");

module.exports = function (deployer) {
  deployer.deploy(VickreyAuction, 200, 200);
};
