var MiningEquity = artifacts.require("./MiningEquityDistributorV2.sol");
module.exports = function(deployer) {
  deployer.deploy(MiningEquity);
};
