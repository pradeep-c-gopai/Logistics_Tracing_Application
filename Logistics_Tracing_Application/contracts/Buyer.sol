// SPDX-License-Identifier: MIT

import "./Seller.sol";

import "./Logistics.sol";

pragma solidity ^0.8.0;

contract Buyer{

    // Seller

    address seller = address(0);

    address logistics = address(0);

    Seller s;

    Logistics L;

    mapping (uint => mapping (address => uint)) internal DeliveryStatusID;

    struct orderedInvoice{

        uint OID;

        uint pricePaid;

        address paidTo;

    }

    mapping (uint => mapping (address=> orderedInvoice)) internal ProductOrderedInvoice;

    mapping (uint => mapping (address => uint)) internal OrderIDs;

    function requestProduct(uint PID) public view returns (uint, 
        string memory, 
        string memory, 
        uint, 
        bool, 
        address){

        require(seller != address(0), "choose Seller First");
        
        return s.requestProductQuotes(PID);

    }

    function viewInvoice(uint OID) public view returns (uint, uint, address, address){

        require(ProductOrderedInvoice[OID][msg.sender].OID != 0, "No Purchases Founds");

        uint _OID = ProductOrderedInvoice[OID][msg.sender].OID;

        uint _toPay = ProductOrderedInvoice[OID][msg.sender].pricePaid;

        address _paidTo = ProductOrderedInvoice[OID][msg.sender].paidTo;

        return (_OID,_toPay,msg.sender,_paidTo);

    }

    function Buy(uint PID, 
        string memory _name, 
        string memory _address,
        uint40 _phone, 
        string memory _email) public payable returns (uint,uint,address){

        require(seller != address(0), "choose Seller First");
        
        require(PID != 0, "invalid PID");

        address _Buyer = msg.sender;

        (uint toPay, address _seller, uint OID) = s.Buy(PID,_Buyer,_name,_address,_phone,_email);

        require(msg.value == toPay, "Low Fund");

        (bool success,) = (_seller).call{value: msg.value}("");

        require(success,"Buy failed!");

        OrderIDs[PID][msg.sender] = OID;

        ProductOrderedInvoice[OID][msg.sender] = orderedInvoice(OID,toPay,_seller); 

        return (OID, toPay, _seller);
    
    }

    function getOrderId(uint PID) public view returns (uint, string memory){

        uint oid = OrderIDs[PID][msg.sender];

        require(oid != 0, "No Order ID Available");

        return (oid," is Order_Id for the product purchased");

    }

    function getExportId(uint OID) public view returns (uint, string memory){
        
        uint ExpoID = DeliveryStatusID[OID][msg.sender];

        require(ExpoID != 0, "No Export ID Available");

        return (ExpoID," is Export_Id for order");

    }

    function chooseSeller(address _seller) public returns(address){

        require(_seller != address(0),"Invalid Seller Contract Address");
        
        seller = _seller;

        s = Seller(_seller);

        return seller;

    }

    function chooseFreighter(address _logistics) public returns(address){

        require(_logistics != address(0),"Invalid Logistics Contract Address");

        logistics = _logistics;

        L = Logistics(logistics);

        return logistics;

    }

    function BookFreighter(uint OID) public payable {

        require(seller != address(0), "choose Seller First and buy product");

        require(logistics != address(0), "Choose Freighter First");
        
        (bool bookingReview, uint freighterPrice, address freightAccount) = L.bookFreight(OID, seller, logistics);

        require(bookingReview, "Booking Review Failed!");

        require(msg.value == freighterPrice, "insufficient Funds");

        (bool success,) = freightAccount.call{value: msg.value}("");

        require(success, "Freight Booking failed at Payment");

    }

    function FreightBookingStatus(uint OID) public view returns (uint,
        string memory,
        uint40,
        string memory,
        string memory,
        bool){

        require(seller != address(0), "choose Seller First and buy product");

        require(logistics != address(0), "Choose Freighter First");

        address _buyer = msg.sender;

        (uint _OID,string memory _name,
        uint40 _phone,
        string memory _address,
        string memory _email,
        bool _status) = L.viewFreightBookings(OID, _buyer);

        return (_OID,_name,_phone,_address,_email,_status);

    }

    function saveExpoID(uint _OID, address _buyerAddress,uint _ExpoID) external {

        require(msg.sender == logistics, "Not Logistics");

        DeliveryStatusID[_OID][_buyerAddress] = _ExpoID;

    }

    

    function productDeliveryStatus(uint expoID) public view returns (uint /*ExpoID*/,
        uint, /*OID*/
        uint, /*PID*/
        bool, /*productHandedOver*/
        string memory /*deliveryStatus*/){

        require(seller != address(0), "choose Seller First and buy product");

        require(logistics != address(0), "Choose Freighter First");
        
        (uint ExpoID,
        uint OID,
        uint PID,
        bool productHandedOver,
        string memory deliveryStatus) = L.deliveryStatus(expoID);

        return (ExpoID,OID,PID,productHandedOver,deliveryStatus);
    }

}






