## **Customer Acquisition APIs** ##
----

# ***Customer Acquisition list***

* **URL:** `BASE_URL + finance/api/v1/customer_acquisitions/
* **Method:** `GET`
* **URL Params:**
```
params do
  use :pagination, per_page: 30, offset: 0
  optional :acquisition_by, type: String, values: %w[Ambassador Partner SR]
  optional :is_paid, type: Boolean, values: [true, false]
  requires :start_date_time, type: DateTime
  requires :end_date_time, type: DateTime
  optional :skip_pagination, type: Boolean
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetch customer acquisition list",
  "data": [
    {
      "id": 143,
      "user_id": 636,
      "registered_by_id": 66,
      "registered_by_type": "Partner",
      "amount": 30.0,
      "coupon_id": 201023,
      "is_paid": false,
      "information_status": "full",
      "created_at": "2022-10-27T12:56:49.605+06:00"
    },
    {
      "id": 73,
      "user_id": 545,
      "registered_by_id": 163,
      "registered_by_type": "Partner",
      "amount": null,
      "coupon_id": null,
      "is_paid": false,
      "information_status": "incomplete",
      "created_at": "2022-10-03T17:00:02.569+06:00"
    }
  ]
}
```

* **Error Response:**
    * **Code:** `200`
  * **Content:**
       ```json 
        {"success": false, "message": "", "status": , "data":   }
       ```
  * **for other error:**
    ```json
    {
    "success": false,
    "status": 422,
    "message": "Unable to fetch the customer acquisition list due to #{error}.",
    "data": {}
    }
    ```
----



## ***Adopt Manual Payment For Customer Acquisition***

* **URL:** `BASE_URL + finance/api/v1/customer_acquisitions/update_payment_status
* **Method:** `PUT`
* **URL Params:**
```
params do
  requires :file, type: File
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully update acquisition payment status",
  "data": {}
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**
         ```json 
          {"success": false, "message": "", "status": , "data":   }
         ```

      * **if acquisition id not matched:**
           ```json 
          {
            "success": false,
            "status": 404,
            "message": "acquisition_id: 10 not found.",
            "data": {}
          }
           ```
      * **if acquisition already paid:**
         ```json 
        {
          "success": false,
          "status": 404,
          "message": "acquisition_id: 10 is already paid",
          "data": {}
        }
         ```
      * **if acquisition information incomplete:**
         ```json 
        {
          "success": false,
          "status": 404,
          "message": "acquisition_id: 10 have incomplete information",
          "data": {}
        }
         ```
        * **for other error:**
        ```json
        {
        "success": false,
        "status": 422,
        "message": "Unable to update acquisition payment status",
        "data": {}
        }
        ```
----
