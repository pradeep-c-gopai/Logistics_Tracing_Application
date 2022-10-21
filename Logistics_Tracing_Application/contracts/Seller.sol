// SPDX-License-Identifier: MIT

import "./Logistics.sol";

pragma solidity ^0.8.0;

contract Seller{

    Logistics L;

    address seller;

    uint PIDCount = 1;

    uint OIDCount = 1;

    struct product{

        uint PID;

        string productName;

        string productDescription;

        uint productPrice;

        string productPickUpAddress;

        bool sold;

        address buyer;

    }

    mapping (uint => product) public Products;

    struct order{

        uint OID; 

        uint PID;

        string productName;

        uint pricePaid;

        address buyerIDAddress;

        address freighterAddress;

        bool ordered;

        bool packed;

        bool handedOver;

    }
    
    mapping (uint => order) public Orders;
    
    struct buyerDetail{

        uint OID;

        address buyerIDAddress;

        string buyerName;

        string buyerPostalAddress;

        uint40 buyerPhone;

        string buyerEmail;

    }

    mapping (uint => buyerDetail) internal BuyerDetails;

    constructor(address _seller) {

        seller = _seller;

    }


    modifier onlySeller() {

        require(msg.sender == seller,"Not Seller");
        _;

    }
    

    function viewBuyerDetails(uint OID) public view onlySeller returns (address,
        string memory,
        string memory, 
        uint40,
        string memory) {
        
        return (BuyerDetails[OID].buyerIDAddress,
        BuyerDetails[OID].buyerName,
        BuyerDetails[OID].buyerPostalAddress,
        BuyerDetails[OID].buyerPhone,
        BuyerDetails[OID].buyerEmail);
        
    }

    function addProduct

        (string memory _productName, 
        string memory _productDescription,
        uint _productPrice,
        string memory pickUpAddress) 
        
        public onlySeller {

        Products[PIDCount] = product(PIDCount,_productName,_productDescription,_productPrice,pickUpAddress,false,address(0));

        PIDCount++;

    }


    function requestProductQuotes(uint _PID) external view returns (uint, 
        string memory, 
        string memory, 
        uint, 
        bool, 
        address) {
        
        require(Products[_PID].PID > 0, "No Product Available");
          
        require(_PID > 0 && _PID <=  PIDCount, "invalid Product_ID");

        return (Products[_PID].PID,
        Products[_PID].productName,
        Products[_PID].productDescription,
        Products[_PID].productPrice,
        Products[_PID].sold,
        Products[_PID].buyer);

    }


    function Buy
    
        (uint pID,
        address _Buyer,
        string memory _name,
        string memory _address,
        uint40 _phone,
        string memory _email)
        
        external payable returns (uint, address, uint) {

        require(msg.sender != seller, "seller can't buy");

        require(_Buyer != address(0), "Invalid Buyer");

        require(pID > 0 && pID <=  PIDCount, "invalid Product_ID");

        require(Products[pID].sold != true, "Already soldout!");

        Products[pID].sold = true;

        Products[pID].buyer = _Buyer;

        uint toPay = Products[pID].productPrice;

        Orders[OIDCount] = order(OIDCount,pID,Products[pID].productName,toPay,_Buyer,address(0),true,false,false);

        BuyerDetails[OIDCount] = buyerDetail(OIDCount,_Buyer,_name,_address,_phone,_email);
        
        uint oid = OIDCount;

        OIDCount++;

        return (toPay, seller, oid);

    }

    function freightValidation(uint OID, address _logistics) external returns (uint,address,
        string memory,
        string memory,
        uint40,
        string memory){

        require(msg.sender == _logistics, "Not a Freighter");

        require(Orders[OID].ordered, "Product Not Ordered!");

        Orders[OID].freighterAddress = _logistics;


        return (Orders[OID].PID,
        BuyerDetails[OID].buyerIDAddress,
        BuyerDetails[OID].buyerName,
        BuyerDetails[OID].buyerPostalAddress,
        BuyerDetails[OID].buyerPhone,
        BuyerDetails[OID].buyerEmail);

    }

    function orderHandOver(uint OID) external returns (uint){
        
        require(Orders[OID].freighterAddress == msg.sender,"Invalid Freighter Address");

        require(Orders[OID].ordered, "Product Not Ordered!");

        require(Orders[OID].packed, "Order Not Packed");

        require(Orders[OID].handedOver != true, "Already Handed Over");

        Orders[OID].handedOver = true;

        return (Orders[OID].PID);

    }

    function packedOrder(uint OID) public onlySeller {

        require(Orders[OID].ordered, "Product Not Ordered!");
        
        require(Orders[OID].packed != true,"Already Packed");

        Orders[OID].packed = true;

    }


}






