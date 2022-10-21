const Seller = artifacts.require("Seller");

const Buyer = artifacts.require("Buyer");

const Logistics = artifacts.require("Logistics");

const PortClearance = artifacts.require("PortClearance");



contract("Testing Buyer contract ", (accounts) => {
    
  const addr = "0x0000000000000000000000000000000000000000";

  it("buyer is deployed and instance can be created", async () => {

    const buyerInstance = await Buyer.deployed();

    assert.notEqual(buyerInstance, null, "buyer instance could not be created");

  });


  it("buyer choose seller", async () => {

    const buyerInstance = await Buyer.deployed();

     const owner = await buyerInstance.chooseSeller.call("0x2e6B07e9cacf366DdB8Ee2714f536F953bAA7103");
     
    assert.notEqual(owner,addr, "seller not be null address");

  });


  it("buyer choose Freighter", async () => {

    const buyerInstance = await Buyer.deployed();

     const owner = await buyerInstance.chooseFreighter.call("0xD721D051Ae5910b46258B98d768330103E861EdB");

    assert.notEqual(owner, addr, "Enter valid address");

  });


});



contract("Testing seller contract ", (accounts) => {

  const addr = "0x0000000000000000000000000000000000000000";

    it("Seller is deployed and instance can be created", async () => {

      const sellerInstance = await Seller.deployed();

      assert.notEqual(sellerInstance, null, "seller instance could not be created");

    });
    
    
  });



contract("Testing Logistics contract ", (accounts) => {

  const addr = "0x0000000000000000000000000000000000000000";

     it("Logistics is deployed and instance can be created", async () => {

        const LogisticsInstance = await Logistics.deployed();

        assert.notEqual(LogisticsInstance, null, "Enter valid address");

    });


    it("Choose Port Clearance", async () => {

        const LogisticsInstance = await Logistics.deployed();

        const owner = await LogisticsInstance.chooseClearncePort.call("0xD721D051Ae5910b46258B98d768330103E861EdB",{from: "0x1c14CdeAaeb6A955209a8B9794b7B5650E6D341b"});

        assert.notEqual(owner, addr, "Enter valid address");

    });

  });


  
  contract("Testing PortClearance contract ", (accounts) => {

    const addr = "0x0000000000000000000000000000000000000000";
  
       it("PortClearance is deployed and instance can be created", async () => {
  
          const PortClearanceInstance = await PortClearance.deployed();
  
          assert.notEqual(PortClearanceInstance, null, "Enter valid address");
  
      });
  
      
    });









