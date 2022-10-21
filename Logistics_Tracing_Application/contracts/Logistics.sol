// SPDX-License-Identifier: MIT

import "./Buyer.sol";

import "./Seller.sol";

import "./PortClearance.sol";

pragma solidity ^0.8.0;

contract Logistics{

    PortClearance P;

    address portClearancecongtractAddress = address(0);

    Buyer B;

    uint ExpoCount = 1;

    address FreightBookingAccount;

    uint freightCharges = 10000000000000000;

    Seller s;

    struct freightBook{

        uint OID;

        uint PID;

        address sellerAddress;

        address buyerAddress;

        address buyerContractAddress;

        string buyerName;

        uint40 buyerPhone;

        string deliveryAddress;

        string buyerEmail;

        bool freightBooked;
        
    }

    mapping (uint => bool) public exportCleared;

    mapping (uint => bool) public importCleared;

    mapping (uint => freightBook) internal FreightBookings;

    struct productDelivery{

        uint ExpoID;

        uint OID;

        uint PID;

        bool productHandedOver;

        bool deliveryInitiated;

        bool exportPort;

        bool importPort;

        bool delivered;

    }

    mapping (uint => productDelivery) public CurrentProductDeliveries;

    mapping (uint => mapping (address => bool)) internal ValidFreightBooker;

    constructor (address adr){

        FreightBookingAccount = adr;

    }

    modifier onlyFreighter() {

        require(msg.sender == FreightBookingAccount,"Not Freighter");
        _;

    }

    function bookFreight(uint OID, address seller, address _logistics) external returns (bool,uint,address){

        require(FreightBookings[OID].freightBooked != true, "Freighter Already Booked");

        address buyerContractAddress = msg.sender;

        s = Seller(seller);

        (uint PID,address buyerIDAddress,
        string memory buyerName,
        string memory deliveryAddress,
        uint40 buyerPhone,
        string memory buyerEmial) = s.freightValidation(OID,_logistics);

        require(PID!=0, "Buy Product First");

        ValidFreightBooker[OID][buyerIDAddress] = true;

        FreightBookings[OID] = freightBook(OID,
        PID,
        seller,
        buyerIDAddress,
        buyerContractAddress,
        buyerName,
        buyerPhone,
        deliveryAddress,
        buyerEmial,
        true);

        return (true,freightCharges,FreightBookingAccount);

    }

    function viewFreightBookings(uint OID, address _caller) external view returns (uint,
        string memory,
        uint40,
        string memory,
        string memory,
        bool){

        require(ValidFreightBooker[OID][_caller], "Not Authorized to View");

        return (FreightBookings[OID].PID,

        FreightBookings[OID].buyerName,

        FreightBookings[OID].buyerPhone,

        FreightBookings[OID].deliveryAddress,

        FreightBookings[OID].buyerEmail,

        FreightBookings[OID].freightBooked);

    }

    function pickProductForExport(uint OID) public onlyFreighter {

        require(FreightBookings[OID].freightBooked, "Freighter Not Booked for export");

        uint pID = s.orderHandOver(OID);

        B = Buyer(FreightBookings[OID].buyerContractAddress);

        B.saveExpoID(OID,FreightBookings[OID].buyerAddress,ExpoCount);

        CurrentProductDeliveries[ExpoCount] = productDelivery(ExpoCount,OID,pID,true,false,false,false,false);

        ExpoCount++;

    }

    function initiateDelivery(uint _ExpoID) public onlyFreighter {

        require(CurrentProductDeliveries[_ExpoID].OID > 0, "Freighter Not Booked");

        require(CurrentProductDeliveries[_ExpoID].productHandedOver, "Product Not handed Over");

        CurrentProductDeliveries[_ExpoID].deliveryInitiated = true;

    }

    function deliveryStatus(uint _ExpoID) external view returns (uint /*ExpoID*/,
        uint, /*OID*/
        uint, /*PID*/
        bool, /*productHandedOver*/
        string memory /*deliveryStatus*/){

        uint oID = CurrentProductDeliveries[_ExpoID].OID;

        (,,,,,,bool _ordered,bool _packed,bool _handedOver) = s.Orders(oID);

        require(FreightBookings[oID].freightBooked, "Freighter Not Booked");

        require(_ordered, "No Orders Available in Seller");

        require(_packed, "Order Not Packed");

        require(_handedOver, "Order Not HandedOver");


        if(CurrentProductDeliveries[_ExpoID].productHandedOver == false){
            return (CurrentProductDeliveries[_ExpoID].ExpoID,
            CurrentProductDeliveries[_ExpoID].OID,
            CurrentProductDeliveries[_ExpoID].PID,
            CurrentProductDeliveries[_ExpoID].productHandedOver,
            "Product Not yet Picked-Up");
        }

        else if(CurrentProductDeliveries[_ExpoID].deliveryInitiated == false){
            return (CurrentProductDeliveries[_ExpoID].ExpoID,
            CurrentProductDeliveries[_ExpoID].OID,
            CurrentProductDeliveries[_ExpoID].PID,
            CurrentProductDeliveries[_ExpoID].productHandedOver,
            "Shipping Starts shortly");
        }
        else if(CurrentProductDeliveries[_ExpoID].exportPort == false){
            return (CurrentProductDeliveries[_ExpoID].ExpoID,
            CurrentProductDeliveries[_ExpoID].OID,
            CurrentProductDeliveries[_ExpoID].PID,
            CurrentProductDeliveries[_ExpoID].productHandedOver,
            "Shipped and delivery to be at Export Port and will be getting export clearance");
        }
        else if(CurrentProductDeliveries[_ExpoID].importPort == false){
            return (CurrentProductDeliveries[_ExpoID].ExpoID,
            CurrentProductDeliveries[_ExpoID].OID,
            CurrentProductDeliveries[_ExpoID].PID,
            CurrentProductDeliveries[_ExpoID].productHandedOver,
            "Will be Arriving at Import Port and will be getting import clearance");
        }
        else if(CurrentProductDeliveries[_ExpoID].delivered == false){
            return (CurrentProductDeliveries[_ExpoID].ExpoID,
            CurrentProductDeliveries[_ExpoID].OID,
            CurrentProductDeliveries[_ExpoID].PID,
            CurrentProductDeliveries[_ExpoID].productHandedOver,
            "Out for Delivery");
        }
        else if(CurrentProductDeliveries[_ExpoID].delivered == true){
            return (CurrentProductDeliveries[_ExpoID].ExpoID,
            CurrentProductDeliveries[_ExpoID].OID,
            CurrentProductDeliveries[_ExpoID].PID,
            CurrentProductDeliveries[_ExpoID].productHandedOver,
            "Delivered");
        }
        else
        {
            return (0,
            0,
            0,
            false,
            "Something went wrong!");
        }
    }

    function chooseClearncePort(address _ClearancePortContract) public onlyFreighter{

        require(_ClearancePortContract != address(0), "Invalid Clearance Port Address");

        portClearancecongtractAddress = _ClearancePortContract;

        P = PortClearance(_ClearancePortContract);

    }


    //Export Port Arrival
    function sourcePortArrival(uint _ExpoID) public onlyFreighter{

        require(CurrentProductDeliveries[_ExpoID].productHandedOver != false, "Product Need to be pickedup first");

        require(CurrentProductDeliveries[_ExpoID].deliveryInitiated != false, "delivery not started");

        require(CurrentProductDeliveries[_ExpoID].importPort != true, "Already arrived at import port");

        uint oID = CurrentProductDeliveries[_ExpoID].OID;

        CurrentProductDeliveries[_ExpoID].exportPort = P.exportPortArrival(_ExpoID,address(this),FreightBookings[oID].sellerAddress);

    }

     //Import Port Arrival
    function destinationPortArrival(uint _ExpoID) public onlyFreighter{

        require(CurrentProductDeliveries[_ExpoID].productHandedOver != false, "Product Need to be pickedup first");

        require(CurrentProductDeliveries[_ExpoID].deliveryInitiated != false, "delivery not started");

        require(CurrentProductDeliveries[_ExpoID].exportPort != false, "Not yet Arrived at export port!");

        (,bool expoCleared,,,)=P.exportClearances(_ExpoID);

        require(expoCleared, "Export Clearance false");

        uint oID = CurrentProductDeliveries[_ExpoID].OID;

        CurrentProductDeliveries[_ExpoID].importPort = P.importPortArrival(_ExpoID, address(this),FreightBookings[oID].buyerAddress);
            
    }


    function deliver(uint _ExpoID) public onlyFreighter {
        
        require(CurrentProductDeliveries[_ExpoID].OID > 0, "Freighter Not Booked");

        require(CurrentProductDeliveries[_ExpoID].productHandedOver != false, "Product Need to be pickedup first");

        require(CurrentProductDeliveries[_ExpoID].deliveryInitiated != false, "delivery not started");

        require(CurrentProductDeliveries[_ExpoID].exportPort != false, "Not yet Arrived at export port!");

        require(exportCleared[_ExpoID] != false, "Export not cleared yet");

        require(importCleared[_ExpoID] != false, "import Not cleared yet");

        CurrentProductDeliveries[_ExpoID].delivered = true;

    }

    function exportVerifiction(uint _expoID, address _Logistics, address _seller) external {

        require(CurrentProductDeliveries[_expoID].OID > 0, "Freighter Invalid Export");

        require(CurrentProductDeliveries[_expoID].deliveryInitiated != false, "Export Shippment pending");

        require(msg.sender == portClearancecongtractAddress, "Not Port ClearanceAuthority");

        require(_Logistics == address(this), "Logistics Address Mismatch");

        uint oID = CurrentProductDeliveries[_expoID].OID;

        require(_seller == FreightBookings[oID].sellerAddress, "Verification Failed for Seller Address");

        require(CurrentProductDeliveries[_expoID].exportPort, "Export Order Not Arrived at export port");

        exportCleared[_expoID] = true;

    }

    function importVerifiction(uint _expoID, address _Logistics, address _buyer) external {

        require(CurrentProductDeliveries[_expoID].OID > 0, "Freighter Invalid Export");

        require(msg.sender == portClearancecongtractAddress, "Not Port ClearanceAuthority");

        require(_Logistics == address(this), "Logistics Address Mismatch");

        uint oID = CurrentProductDeliveries[_expoID].OID;

        require(_buyer == FreightBookings[oID].buyerAddress, "Verification Failed for buyer Address");

        require(CurrentProductDeliveries[_expoID].importPort, "Export Order Not Arrived at export port");

        importCleared[_expoID] = true;

    }


}




