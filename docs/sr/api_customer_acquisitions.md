## **Customer Acquisition APIs** ##
----

## ***Remote uniqueness check.***

* **URL**: `BASE_URL + api/v1/customer_acquisitions/remote_uniqueness_and_validation_check
* **Method:** `GET`
* **URL Params:** `None`
```
params do
  requires :content, type: String
  requires :field_name, type: String, values: %w[phone whatsapp viber imo nid]
end
```
* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully check remote uniqueness and validation.",
  "data": {
    "validate": true
  }
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**
    * **if field name not exist:**
      ```json
      {
      "success": false,
      "status": 404,
      "message": "Unable to check remote uniqueness due to provided field is not exist",
      "data": {}
      }
      ```
    * **for other error:**
      ```json
      {
      "success": false,
      "status": 422,
      "message": "Unable to check remote uniqueness due to #{error}.",
      "data": {}
      }
      ```
----

## ***Customer Acquisitions***

* **URL:** `BASE_URL + api/v1/customer_acquisitions
* **Method:** `POST`
* **URL Params:**
 ```
params do
  requires :full_name, type: String
  requires :phone, type: String
  requires :gender, type: String, values: %w[female male others]
  requires :date_of_birth, type: Date
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 201,
  "message": "Successfully complete customer acquisition.",
  "data": {}
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**
      ```json
      {
      "success": false,
      "status": 422,
      "message": "Unable to complete customer acquisitions.",
      "data": {}
      }
      ```
----


## ***Customer Acquisition Update Additional Info***

* **URL:** `BASE_URL + api/v1/customer_acquisitions
* **Method:** `POST`
* **URL Params:**
 ```
params do
  optional :whatsapp, type: String
  optional :viber, type: String
  optional :imo, type: String
  requires :home_address, type: String
  requires :nid, type: Date
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 201,
  "message": "Successfully update customer info.",
  "data": {}
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**
      ```json
      {
      "success": false,
      "status": 422,
      "message": "Unable to update customer info.",
      "data": {}
      }
      ```
----

## ***Verify OTP***

* **URL:** `BASE_URL + api/v1/customer_acquisitions/:id/otp_verify
* **Method:** `PUT`
* **URL Params:**
```
params do
  requires :otp, type: String
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully verify otp.",
  "data": {}
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
          "message": "Unable to verify otp due to provided record not found.",
          "data": {}
        }
         ```
      * **for other error:**
        ```json
        {
        "success": false,
        "status": 422,
        "message": "Unable to verify otp due to #{error}.",
        "data": {}
        }
        ```
----

## ***Greetings(Thanks Button) For Customer Acquisition***

* **URL:** `BASE_URL + api/v1/customer_acquisitions/:id/greetings
* **Method:** `GET`
* **URL Params:**
*
* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "The customer will receive a 10% voucher, and you will receive BDT 20, for registration.",
  "data": {}
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
          "message": "Greetings is interrupted due to record is not found.",
          "data": {}
        }
         ```
        * **for other error:**
          ```json
          {
          "success": false,
          "status": 422,
          "message": "Greetings is interrupted. due to #{error}.",
          "data": {}
          }
          ```
