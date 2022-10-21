// SPDX-License-Identifier: MIT

import "./Logistics.sol";

pragma solidity ^0.8.0;

contract PortClearance{

    Logistics L;

    address ExportClearanceAuthority;

    address importClearanceAuthority;

    struct exportClear{
        bool arrival;
        bool cleared;
        address LogisticsAddress;
        address sellerAddress;
        uint ExpoID;
    }

    mapping (uint => exportClear) public exportClearances;

    struct importClear{
        bool arrival;
        bool cleared;
        address LogisticsAddress;
        address buyerAddress;
        uint ExpoID;
    }

    mapping (uint => importClear) public importClearances;

    constructor(address _ExportClearanceAuthority,address _importClearanceAuthority){
        ExportClearanceAuthority = _ExportClearanceAuthority;
        importClearanceAuthority = _importClearanceAuthority;
    }

    modifier onlyExportClearance{
        require(msg.sender == ExportClearanceAuthority, "NOT EXPO AUTHORITY");
        _;
    }

    modifier onlyImportClearance{
        require(msg.sender == importClearanceAuthority, "NOT EXPO AUTHORITY");
        _;
    }

    function exportPortArrival(uint ExpoID,address _LogisticsContractAddress, address _SellerAddress) external returns (bool){
        exportClearances[ExpoID].arrival = true;
        exportClearances[ExpoID].LogisticsAddress = _LogisticsContractAddress;
        exportClearances[ExpoID].sellerAddress = _SellerAddress;
        return exportClearances[ExpoID].arrival;
    }

    function importPortArrival(uint ExpoID, address _LogisticsContractAddress, address _buyerAddress) external returns (bool){
        importClearances[ExpoID].arrival = true;
        importClearances[ExpoID].LogisticsAddress = _LogisticsContractAddress;
        importClearances[ExpoID].buyerAddress = _buyerAddress;
        return importClearances[ExpoID].arrival;
    }

    function ExportClearance(uint ExpoID) public onlyExportClearance {

        L = Logistics(exportClearances[ExpoID].LogisticsAddress);

        L.exportVerifiction(ExpoID,exportClearances[ExpoID].LogisticsAddress,exportClearances[ExpoID].sellerAddress);

        exportClearances[ExpoID].cleared = true;
        
    }

    function importClearance(uint ExpoID) public onlyImportClearance {

        L = Logistics(importClearances[ExpoID].LogisticsAddress);

        L.importVerifiction(ExpoID,importClearances[ExpoID].LogisticsAddress,importClearances[ExpoID].buyerAddress);

        importClearances[ExpoID].cleared = true;
    }

}









