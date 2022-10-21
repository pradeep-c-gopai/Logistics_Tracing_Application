const Seller = artifacts.require("Seller");

module.exports = async function (deployer) {
  deployer.deploy(Seller,"0x3FA2C45968D36f025782184Bd6f762BFEEff02b1");
};