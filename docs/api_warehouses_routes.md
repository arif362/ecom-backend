                    Update a Wh_Purchase_Order

* **URL**: `BASE_URL + /api/v1/warehouses/routes`

* **Method:** `GET`

*  **URL Params:**
   `{
   "start_date_time": 2021-12-27,
   "end_date_time": 2022-12-27,
   "per_page": 15,
   "page": 1,
   "distributor_id": 1,
   "title": "Rider",
   }
   `

* **Success Response:**
 ```json
 [
   {
      "id": 117,
      "title": "Hero Honda Route",
      "sr_name": "SR Honda",
      "sr_point": "SR Honda Store",
      "bn_title": "হিরো হোন্ডা রাউট ",
      "phone": "01818995776",
      "prepaid_order_count": 0,
      "total_order": 0,
      "collected_by_sr": "0.0",
      "collected_by_fc": "0.0"
   },
   {
      "id": 116,
      "title": "Siam Routes",
      "sr_name": "Siam",
      "sr_point": "1",
      "bn_title": "হ্যালো",
      "phone": "01788628782",
      "prepaid_order_count": 0,
      "total_order": 1,
      "collected_by_sr": "12000.0",
      "collected_by_fc": "12000.0"
   },
   {
      "id": 112,
      "title": "Route-a",
      "sr_name": "Moshiur",
      "sr_point": "Moshiur SR",
      "bn_title": "Route-a",
      "phone": "01517816145",
      "prepaid_order_count": 0,
      "total_order": 0,
      "collected_by_sr": "0.0",
      "collected_by_fc": "635.0"
   },
   {
      "id": 71,
      "title": "Route reconciliation testing",
      "sr_name": "Route reconciliation",
      "sr_point": "Route reconciliation",
      "bn_title": "Route reconciliation testing",
      "phone": "01967579586",
      "prepaid_order_count": 0,
      "total_order": 0,
      "collected_by_sr": "0.0",
      "collected_by_fc": "0.0"
   }
]
```
* **Error Response:**
    * **Content:**
         ```json 
          { "message": "Validation failed: ***", "status_code": 422 }
         ```


                    Update a Wh_Purchase_Order

* **URL**: `BASE_URL + /api/v1/warehouses/routes_export`

* **Method:** `GET`

*  **URL Params:**
   `{
   "start_date_time": 2021-12-27,
   "end_date_time": 2022-12-27,
   "distributor_id": 1,
   "title": "Rider",
   }
   `

* **Success Response:**
 ```json
 [
   {
      "id": 117,
      "title": "Hero Honda Route",
      "sr_name": "SR Honda",
      "sr_point": "SR Honda Store",
      "bn_title": "হিরো হোন্ডা রাউট ",
      "phone": "01818995776",
      "prepaid_order_count": 0,
      "total_order": 0,
      "collected_by_sr": "0.0",
      "collected_by_fc": "0.0"
   },
   {
      "id": 116,
      "title": "Siam Routes",
      "sr_name": "Siam",
      "sr_point": "1",
      "bn_title": "হ্যালো",
      "phone": "01788628782",
      "prepaid_order_count": 0,
      "total_order": 1,
      "collected_by_sr": "12000.0",
      "collected_by_fc": "12000.0"
   },
   {
      "id": 112,
      "title": "Route-a",
      "sr_name": "Moshiur",
      "sr_point": "Moshiur SR",
      "bn_title": "Route-a",
      "phone": "01517816145",
      "prepaid_order_count": 0,
      "total_order": 0,
      "collected_by_sr": "0.0",
      "collected_by_fc": "635.0"
   },
   {
      "id": 71,
      "title": "Route reconciliation testing",
      "sr_name": "Route reconciliation",
      "sr_point": "Route reconciliation",
      "bn_title": "Route reconciliation testing",
      "phone": "01967579586",
      "prepaid_order_count": 0,
      "total_order": 0,
      "collected_by_sr": "0.0",
      "collected_by_fc": "0.0"
   }
]

