const BarbossaBrethren = artifacts.require("BarbossaBrethren");

module.exports = function (deployer) {
  deployer.deploy(BarbossaBrethren, 200, 200);
};
