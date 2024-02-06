
**Challan API's**
----
***Get all challans***

* **URL**: `BASE_URL + distributor/api/v1/challans
* **Method:** `GET`
* **URL Params:** `None`

* **Success Response:**
 ```json
 {
  "success": true,
  "status": 200,
  "message": "Challans fetched successfully",
  "data": [
    {
      "id": 1,
      "status": "in_transit_to_dh",
      "distributor_id": 1,
      "distributor_name": "test distributor",
      "challan_line_items": null,
      "created_by_id": 7,
      "created_at": "2022-07-26T16:13:08.586+06:00"
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
      "message": "Unable to fetch challan.",
      "data": {}
      }
      ```



***Get a specific challan details.***

* **URL**: `BASE_URL + distributor/api/v1/challans/:id
* **Method:** `GET`
* **URL Params:** `None`

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Challan fetched successfully",
  "data": {
    "id": 1,
    "status": "in_transit_to_dh",
    "distributor_id": 1,
    "distributor_name": "test distributor",
    "challan_line_items": [
      {
        "id": 1,
        "status": "pending",
        "order": {
          "id": 3321,
          "status": "in_transit_to_dh",
          "pay_type": "online_payment",
          "is_customer_paid": true,
          "shipping_type": "home_delivery",
          "total_price": "10826.0"
        }
      }
    ],
    "created_by_id": 7,
    "created_at": "2022-07-26T16:13:08.586+06:00"
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
      "message": "Unable to fetch challan.",
      "data": {}
      }
      ```
    * **for other error:**
      ```json
      {
      "success": false,
      "status": 422,
      "message": "Unable to fetch challan.",
      "data": {}
      }
      ```

***Challan Received***

* **URL:** `BASE_URL + distributor/api/v1/challans/:id/received
* **Method:** `PUT`
* **URL Params:**
    ```
    params do
        requires :order_ids, type: Array
    end
    ```
* **Success Response:**
 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully received challan.",
  "data": {
    "id": 1,
    "status": "completed",
    "distributor_id": 1,
    "distributor_name": "test distributor",
    "challan_line_items": [
      {
        "id": 1,
        "status": "received",
        "order": {
          "id": 3321,
          "status": "qc_pending",
          "pay_type": "online_payment",
          "is_customer_paid": false,
          "shipping_type": "home_delivery",
          "total_price": "10826.0"
        }
      },
      {
        "id": 2,
        "status": "received",
        "order": {
          "id": 3358,
          "status": "qc_pending",
          "pay_type": "nagad_payment",
          "is_customer_paid": false,
          "shipping_type": "home_delivery",
          "total_price": "490.0"
        }
      }
    ],
    "created_by_id": 7,
    "created_at": "2022-07-26T16:13:08.586+06:00"
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
          "message": "Unable to received challan.",
          "data": {}
        }
         ```
        * **for other error:**
          ```json
          {
          "success": false,
          "status": 422,
          "message": "Unable to received challan.",
          "data": {}
          }
          ```

