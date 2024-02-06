**Challan APIs**
----
***Get all challans***

* **URL**: `BASE_URL + api/v1/challans
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
      "status": "initiated",
      "distributor_id": 1,
      "distributor_name": "test distributor",
      "challan_line_items_attributes": null,
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

##### Fetch customer orders for chalan creation

* **URL**: `BASE_URL + api/v1/challans/orders
* **Method:** `GET`
* **URL Params:**

 ```json
{
  "skip_pagination": false,
  // optional
  "start_date_time": "13-06-2022",
  // optional
  "end_date_time": "13-06-2022",
  // optional,
  "distributor_id": 34
  // required,
}
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched customer orders.",
  "data": [
    {
      "id": 5375,
      "order_status": "ready to ship from fc",
      "status_type": "ready_to_ship_from_fc",
      "shipping_type": "home_delivery",
      "pay_status": "non_extended",
      "is_customer_paid": false,
      "order_type": "organic",
      "total_price": "305.0",
      "warehouse_name": "Narshingdi"
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
  "message": "Unable to fetch customer orders.",
  "data": {}
  }
  ```

***Get a specific challan details.***

* **URL**: `BASE_URL + api/v1/challans/:id
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
    "status": "initiated",
    "distributor_id": 1,
    "distributor_name": "test distributor",
    "challan_line_items": [
      {
        "id": 1,
        "status": "pending",
        "order": {
          "id": 3321,
          "status": "ready_to_ship_from_fc",
          "pay_type": "online_payment",
          "is_customer_paid": false,
          "shipping_type": "home_delivery",
          "total_price": "10826.0"
        }
      },
      {
        "id": 2,
        "status": "pending",
        "order": {
          "id": 3358,
          "status": "ready_to_ship_from_fc",
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

***Create a challan***

* **URL:** `BASE_URL + api/v1/challans
* **Method:** `POST`
* **URL Params:**

 ```
params do
  requires :distributor_id, type: Integer
  requires :order_ids, type: Array
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 201,
  "message": "Successfully created challan.",
  "data": {
    "id": 1,
    "status": "initiated",
    "distributor_id": 1,
    "distributor_name": "test distributor",
    "challan_line_items": [
      {
        "id": 1,
        "status": "pending",
        "order": {
          "id": 3321,
          "status": "ready_to_ship_from_fc",
          "pay_type": "online_payment",
          "is_customer_paid": false,
          "shipping_type": "home_delivery",
          "total_price": "10826.0"
        }
      },
      {
        "id": 2,
        "status": "pending",
        "order": {
          "id": 3358,
          "status": "ready_to_ship_from_fc",
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
      {
      "success": false,
      "status": 422,
      "message": "Unable to create challan.",
      "data": {}
      }
      ```

***Dispatch a challan***

* **URL:** `BASE_URL + api/v1/challans/:id/dispatch
* **Method:** `PUT`
* **URL Params:**

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully dispatch challan.",
  "data": {
    "id": 1,
    "status": "initiated",
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
          "is_customer_paid": false,
          "shipping_type": "home_delivery",
          "total_price": "10826.0"
        }
      },
      {
        "id": 2,
        "status": "pending",
        "order": {
          "id": 3358,
          "status": "in_transit_to_dh",
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
          "message": "Unable to dispatch challan.",
          "data": {}
        }
         ```
      * **for other error:**
        ```json
        {
        "success": false,
        "status": 422,
        "message": "Unable to dispatch challan.",
        "data": {}
        }
        ```

***Delete order from challan.***

* **URL**: `BASE_URL + api/v1/challans/:id/remove_order
* **Method:** `DELETE`
* **URL Params:** `None`
    ```
     params do 
        requires :order_id
     end
    ```
* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Remove order from challan successfully",
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
      "message": "Unable to remove order from challan.",
      "data": {}
      }
      ```

***Delete a challan.***

* **URL**: `BASE_URL + api/v1/challans/:id
* **Method:** `DELETE`
* **URL Params:** `None`

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully deleted challan.",
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
