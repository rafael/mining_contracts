var MiningEquity = artifacts.require("./MiningOperation.sol");

module.exports = function(deployer) {
  var owners = [process.env.MINING_OPERATION_ADDR_1, process.env.MINING_OPERATION_ADDR_2];
  var percentage = [50, 50];
  deployer.deploy(MiningEquity, owners, percentage);
};
