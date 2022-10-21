# PROJECT: LOGISTIC TRACING APPLICATION WITH ETHEREUM AND GANACHE.

## Status:

* Completed


### Prerequisites to be followed before deployment:

* Set seller account address in '2_migrations.sol' file. Doing soo, gives the Authorized OwnerShip for the seller account.

* Set Logistics account address in '4_migrations.sol' file. Doing soo, gives the Authorized OwnerShip for the Logistics account.

* Set Export Clearnce and Import Clearance Port account addresses respectively in '5_migrations.sol' file. Doing so, gives the Authorized Ownerships for the export_port_clearance account and import_port_clearance account respectively.

### Customisation after deploying contracts on ganache:

* Setting Contract address of BuyerContractAddress, SellerContractAddress, LogisticsContractAddress, and PortClearanceContractAddress in 'index.html'.

### Complete Application Sequence flow:

    -> Seller        - Add Product (by providing some parameters including Product_Name, Description, Price, PickUp_Address) {onlySeller Modifier used}

    -> Buyer         - chooseSeller (Seller_Contract_Address)

    -> Buyer         - requestProductQuotes (display product details using product ID incuding Product ID, Name, Description, Price (Wei), Sold, Buyer Address)

    -> Buyer         - Buy (buys product by providing product_ID, Buyer_Name, Delivery_Address, Buyer_Phone, Buyer_EmailID)

    -> Buyer         - Get Order_ID (gets order ID by providing product ID of the purchased product)

    -> Buyer         - viewInvoice (Orders invoice Details such has order_ID, Paid_Amount, Paid_From, Paid_To)

    -> Seller        - View Orders (order details along with other information like packed, handedover to logistics)

    -> Seller        - View Buyer Details (Buyer's personal details incuding Buyer_account_Address, Name, Delivery_Address, Phone, Email_ID) {onlySeller Modifier used}

    -> Buyer         - chooseFreighter (Freighter_Contract_Address)

    -> Buyer         - BookFreighter (Booking Logistics for the product ordered)

    -> Buyer         - FreightBookingStatus (View Booking status for the product ordered include Order_ID, Name, Phone, Address, Email, Status)

    -> Seller        - Pack Order (packs the order for the entered ordered ID) {onlySeller Modifier used}

    -> Logistics     - Pickup Order (by providing order ID) {onlyLogistics Modifier used}

    -> Buyer         - Get Export ID (gets Export ID by providing Order ID got for purchased product)

    -> Buyer         - Track Delivery (by providing Export ID, gets the details including Export_ID, Order_ID, Product_ID, ProductHandedOver, Delivery_Status)

    -> Logistics     - Initiate Delivery (by providing Export ID) {onlyLogistics Modifier used}

    -> Logistics     - Source Port Arrival (by providing Export ID it changes the state of export to arrived at source port) {onlyLogistics Modifier used}

    -> PortClearance - Provide Export Clearance (by providing the Export ID, the export authority provide clearance) {onlyExportClearanceAuthority Modifier used}

    -> Logistics     - Destination Port Arrival (by providing Export ID it changes the state of export to arrived at Destination port) {onlyImportClearanceAuthority Modifier used}

    -> PortClearance - Provide Import Clearance (by providing the Export ID, the import authority provide clearance) {onlyExportClearanceAuthority Modifier used}

    -> Logistics     - Deliver (by providing Export ID it changes the state of export to Delivered) {onlyImportClearanceAuthority Modifier used}




    
