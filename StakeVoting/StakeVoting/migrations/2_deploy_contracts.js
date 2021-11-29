const StakeVoting = artifacts.require("StakeVoting");

module.exports = function(deployer) {
  deployer.deploy(StakeVoting);
};
