## **Partners APIs** ##
----

## ***Add bKash Number to Partner profile***

* **URL:** `BASE_URL + api/v1/route_devices/add_bkash_number
* **Method:** `PUT`
* **URL Params:**
```
params do
  requires :bkash_number, type: String
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "bkash number added successfully",
  "data": {}
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**
         ```json 
          {"message": "", "status_code": ...}
         ```

  * **if bkash number already taken:**
    ```json 
    {
     "message": "bkash number has already been taken",
     "status_code": 403
    }
    ```
  * **for other error:**
    ```json
    {
    "status_code": 422,
    "message": "Unable to add bKash number"
    }
    ```
----
