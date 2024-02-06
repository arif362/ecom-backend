
**ReturnChallan API's**
----
***Get all return_challans***

* **URL**: `BASE_URL + api/v1/return_challans
* **Method:** `GET`
* **URL Params:** `None`
```
params do
  optional :status, type: String, values: ["initiated", "in_transit_to_fc", "partially_received", "completed"]
  optional :distributor_id, type: Integer
end
```

* **Success Response:**
 ```json
 {
  "success": true,
  "status": 200,
  "message": "ReturnChallans fetched successfully",
  "data": [
    {
      "id": 2,
      "status": "initiated",
      "distributor_id": 1,
      "distributor_name": "test distributor",
      "customer_orders": null,
      "return_customer_orders": null,
      "created_by_id": 73,
      "created_at": "2022-07-28T16:13:09.725+06:00"
    },
    {
      "id": 1,
      "status": "in_transit_to_fc",
      "distributor_id": 1,
      "distributor_name": "test distributor",
      "customer_orders": null,
      "return_customer_orders": null,
      "created_by_id": 73,
      "created_at": "2022-07-28T15:52:08.379+06:00"
    }
  ]
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**
         ```json
      {
      "success": false,
      "status": 422,
      "message": "Unable to fetch return_challan.",
      "data": {}
      }
      ```

***Get a specific return_challan details.***

* **URL**: `BASE_URL + api/v1/return_challans/:id
* **Method:** `GET`
* **URL Params:** `None`

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "ReturnChallan fetched successfully",
  "data": {
    "id": 1,
    "status": "completed",
    "distributor_id": 1,
    "distributor_name": "test distributor",
    "customer_orders": [
      {
        "id": 4,
        "return_challan_line_item_status": "received_by_fc",
        "status": "packed_cancelled",
        "pay_type": "cash_on_delivery",
        "is_customer_paid": false,
        "shipping_type": "home_delivery",
        "total_price": "180.0"
      }
    ],
    "return_customer_orders": [
      {
        "id": 100,
        "return_challan_line_item_status": "received_by_fc",
        "return_status": "qc_pending",
        "return_type": "unpacked",
        "sub_total": "0.0"
      },
      {
        "id": 97,
        "return_challan_line_item_status": "received_by_fc",
        "return_status": "delivered_to_dh",
        "return_type": "unpacked",
        "sub_total": "0.0"
      }
    ],
    "created_by_id": 73,
    "created_at": "2022-07-28T15:52:08.379+06:00"
  }
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**
    * **if id not matched:**
      ```json
      {
      "success": false,
      "status": 404,
      "message": "Unable to fetch return_challan.",
      "data": {}
      }
      ```
    * **for other error:**
      ```json
      {
      "success": false,
      "status": 422,
      "message": "Unable to fetch return_challan.",
      "data": {}
      }
      ```


***ReturnChallan Received***

* **URL:** `BASE_URL + api/v1/return_challans/:id/received
* **Method:** `PUT`
  * **URL Params:**
      ```
      params do
        optional :cancelled_order_ids, type: Array
        optional :returned_order_ids, type: Array
      end
      ```
* **Success Response:**
 ```json
{
  "success": true,
  "status": 200,
  "message": "ReturnChallan received successfully",
  "data": {
    "id": 1,
    "status": "completed",
    "distributor_id": 1,
    "distributor_name": "test distributor",
    "customer_orders": [
      {
        "id": 4,
        "return_challan_line_item_status": "received_by_fc",
        "status": "packed_cancelled",
        "pay_type": "cash_on_delivery",
        "is_customer_paid": false,
        "shipping_type": "home_delivery",
        "total_price": "180.0"
      }
    ],
    "return_customer_orders": [
      {
        "id": 100,
        "return_challan_line_item_status": "received_by_fc",
        "return_status": "qc_pending",
        "return_type": "unpacked",
        "sub_total": "0.0"
      },
      {
        "id": 97,
        "return_challan_line_item_status": "received_by_fc",
        "return_status": "delivered_to_dh",
        "return_type": "unpacked",
        "sub_total": "0.0"
      }
    ],
    "created_by_id": 73,
    "created_at": "2022-07-28T15:52:08.379+06:00"
  }
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**
         ```json 
          {"success": false, "message": "", "status_code": , "data":   }
         ```

    * **if id not matched:**
         ```json 
        {
          "success": false,
          "status": 404,
          "message": "Unable to received return challan.",
          "data": {}
        }
         ```
        * **for other error:**
          ```json
          {
          "success": false,
          "status": 422,
          "message": "Unable to received return challan.",
          "data": {}
          }
          ```

