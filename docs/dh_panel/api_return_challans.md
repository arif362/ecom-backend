
**ReturnChallan API's**
----
***Get all return_challans***

* **URL**: `BASE_URL + distributor/api/v1/return_challans
* **Method:** `GET`
* **URL Params:** `None`
```
params do
  optional :status, type: String, values: ["initiated", "in_transit_to_fc", "partially_received", "completed"]
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

***Get all available order list for return_challans***

* **URL**: `BASE_URL + distributor/api/v1/return_challans/available_orders
* **Method:** `GET`
  * **URL Params:** `None`
    ```
    params do
      requires :order_type, type: String, values: %w[CustomerOrder ReturnCustomerOrder]
    end
    ```
* **Success Response:**
 ```json
 {
  "success": true,
  "status": 200,
  "message": "CustomerOrder fetched successfully",
  "data": [
    {
      "order_id": 4870,
      "status": "Cancelled",
      "status_type": "cancelled_at_dh",
      "shipping_type": "pick_up_point",
      "order_type": "organic",
      "price": "300.0",
      "warehouse_name": "Narshingdi",
      "date": "2022-06-08T12:09:55.732+06:00"
    },
    {
      "order_id": 4796,
      "status": "Cancelled",
      "status_type": "cancelled_at_dh",
      "shipping_type": "pick_up_point",
      "order_type": "organic",
      "price": "470.0",
      "warehouse_name": "Narshingdi",
      "date": "2022-06-02T19:40:11.998+06:00"
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
      "message": "Unable to fetch CustomerOrder.",
      "data": {}
      }
      ```


***Get a specific return_challan details.***

* **URL**: `BASE_URL + distributor/api/v1/return_challans/:id
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
    "status": "in_transit_to_fc",
    "distributor_id": 1,
    "distributor_name": "test distributor",
    "customer_orders": [],
    "return_customer_orders": [
      {
        "id": 4,
        "return_challan_line_item_status": "pending",
        "return_status": "in_transit_to_fc",
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
      

***Create a return_challan***

* **URL:** `BASE_URL + distributor/api/v1/return_challans
* **Method:** `POST`
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
  "message": "ReturnChallan created successfully",
  "data": {
    "id": 3,
    "status": "initiated",
    "distributor_id": 1,
    "distributor_name": "test distributor",
    "customer_orders": [
      {
        "id": 4,
        "return_challan_line_item_status": "pending",
        "status": "in_transit_to_fc",
        "pay_type": "cash_on_delivery",
        "is_customer_paid": false,
        "shipping_type": "home_delivery",
        "total_price": "180.0"
      }
    ],
    "return_customer_orders": [
      {
        "id": 100,
        "return_challan_line_item_status": "pending",
        "return_status": "delivered_to_dh",
        "return_type": "unpacked",
        "sub_total": "0.0"
      },
      {
        "id": 97,
        "return_challan_line_item_status": "pending",
        "return_status": "delivered_to_dh",
        "return_type": "unpacked",
        "sub_total": "0.0"
      }
    ],
    "created_by_id": 73,
    "created_at": "2022-07-28T18:56:05.187+06:00"
  }
}
```
* **Error Response:**
    * **Code:** `200`
    * **Content:**
      ```json
      {
      "success": false,
      "status": 422,
      "message": "Unable to create return_challan.",
      "data": {}
      }
      ```

***Dispatch a challan***

* **URL:** `BASE_URL + distributor/api/v1/return_challans/:id/dispatch
* **Method:** `PUT`
* **URL Params:**

* **Success Response:**
 ```json
{
  "success": true,
  "status": 200,
  "message": "ReturnChallan dispatch successfully",
  "data": {
    "id": 1,
    "status": "in_transit_to_fc",
    "distributor_id": 1,
    "distributor_name": "test distributor",
    "customer_orders": [
      {
        "id": 4,
        "return_challan_line_item_status": "pending",
        "status": "in_transit_to_fc",
        "pay_type": "cash_on_delivery",
        "is_customer_paid": false,
        "shipping_type": "home_delivery",
        "total_price": "180.0"
      }
    ],
    "return_customer_orders": [
      {
        "id": 4,
        "return_challan_line_item_status": "pending",
        "return_status": "in_transit_to_fc",
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
          "message": "Unable to dispatch return challan.",
          "data": {}
        }
         ```
        * **for other error:**
          ```json
          {
          "success": false,
          "status": 422,
          "message": "Unable to dispatch return challan.",
          "data": {}
          }
          ```

***Delete order from return challan.***
* **URL**: `BASE_URL + distributor/api/v1/return_challans/:id/remove_order
* **Method:** `DELETE`
* **URL Params:** `None`
    ```
     params do
       requires :orderable_id, type: Integer
       requires :orderable_type, type: String 
     end
    ```
* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Remove order from return challan successfully",
  "data": {}
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
      "message": "Challan not found",
      "data": {}
      }
      ```
    * **for other error:**
      ```json
      {
      "success": false,
      "status": 422,
      "message": "Unable to remove order from return challan.",
      "data": {}
      }
      ```


***Delete a return_challan.***
* **URL**: `BASE_URL + distributor/api/v1/return_challans/:id
* **Method:** `DELETE`
* **URL Params:** `None`

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully deleted return_challan.",
  "data": {}
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
