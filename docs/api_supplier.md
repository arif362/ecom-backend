**Supplier API **
----

* **URL**: ``BASE_URL + /shop/api/v1/suppliers``

* **Method:** `POST`

*  **URL Params:**
   `{ "supplier": {
   "company": "xyz",
   "bn_company": "abc",
   "email": "abc@gmail.com",
   "phone": "+8801312456789",
   "bn_phone": "+8801312456789",
   "contact_person": "whoever",
   "contact_person_email": "xyz@gmail.com",
   "contact_person_phone": "8801312456789",
   "mou_document_number": "asdfg",
   "supplier_name": "xyz",
   "bn_supplier_name": "abc",
   "supplier_representative": "whoever",
   "bn_supplier_representative": "whoever",
   "representative_designation": "QA",
   "bn_representative_designation": "QA",
   "representative_contact": "8801312456789",
   "bn_representative_contact": "8801312456789",
   "supplier_email": "supplier@shpoth.com",
   "tin": "fwdhgfw",
   "bin": "nxjksacsk",
   "contract_start_date": "15/12/2020",
   "contract_end_date": "20/12/2020",
   "bank_name": "BRAC",
   "bn_bank_name": "BRAC",
   "account_number": "12469872268411",
   "swift_code": "asdr",
   "bn_swift_code": "asdf",
   "central_warehouse_address": "bhjsh",
   "bn_central_warehouse_address": "mxaxn",
   "local_warehouse_address": "cnjsdcnsd",
   "bn_local_warehouse_address": "ncscn",
   "pre_payment": 0,
   "product_quality_rating": 4.5,
   "deliver_time_rating": 4.0,
   "service_quality_rating": 3.0,
   "professionalism_rating": 4.0,
   "post_payment": 1,
   "credit_payment": 1,
   "credit_days": 10,
   "credit_limit": 1000000000000,
   "agami_kam_name": "mxsac",
   "bn_agami_kam_name": "nxsam",
   "agami_kam_contact": "xmasklxc",
   "bn_agami_kam_contact": "xmasxma",
   "agami_kam_email": "kam@agami.com",
   "delivery_responsibility": "asdf",
   "bn_delivery_responsibility": "asdf",
   "product_lead_time": 10,
   "return_days": 5,
   "pickup_locations": ["mirpur", "banani", "mohakhali"],
   "bn_pickup_locations": ["mirpur", "banani", "mohakhali"],
   "address_attributes": [{
   "address_line": "amalk",
   "bn_address_line": "xmaslkx",
   "district_id": 1,
   "thana_id": 1,
   "area_id": 1
   }]
   },
   "billing_address_id": "1",
   "shipping_address_id": "2"
   }`

* **Success Response:**
 ```json
```

* **Code:** `201`
* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "Unable to update Supplier with id 1 due to error_message.", 422 }
         ```

