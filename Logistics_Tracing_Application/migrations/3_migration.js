const Buyer = artifacts.require("Buyer");

module.exports = async function (deployer) {
  deployer.deploy(Buyer);
};