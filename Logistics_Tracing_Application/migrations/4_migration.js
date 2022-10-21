const Logistics = artifacts.require("Logistics");

module.exports = async function (deployer) {
  deployer.deploy(Logistics,"0x1c14CdeAaeb6A955209a8B9794b7B5650E6D341b");
};