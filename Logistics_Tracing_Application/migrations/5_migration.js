const PortClearance = artifacts.require("PortClearance");

module.exports = async function (deployer) {
  deployer.deploy(PortClearance,"0xc645D933d3467474d421eB15c4a544977BA7194E","0x521346536afF58a7D3FFBe249B7353afD30Bd795");
};