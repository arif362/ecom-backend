**E-com app Tracking API's**
----

Store Device info

* **URL**: ``BASE_URL + /shop/api/v1/customer_devices``

* **Method:** `POST`

* **URL Params:**
* params do
    * requires :customer_device, type: Hash do
        * requires :device_id, type: String
        * requires :device_model, type: String
        * requires :device_os_type, type: String
        * requires :device_os_version, type: String
        * optional :email, type: String
        * optional :phone, type: String
        * optional :user_id, type: Integer
        * optional :app_version, type: String
        * optional :app_language, type: String
        * requires :fcm_id, type: String
        * optional :ip, type: String
        * optional :brand, type: String
        * optional :imei, type: String
    * end
* end

* **Success Response:**
* **Code:** `201`
  * **Content:**

```json
 {
  "success": true,
  "status": 201,
  "message": "Successfully created",
  "data": {
    "customer_device_id": 5
  }
}
```

* ** Error Response:*
* **Code:** '400'
  * **If any error occurred which is missing any required fields then:**
  * **Content:**
```json
{
  "error": "customer_device[device_id] is missing"
}
```

* ** Error Response:*
* **Code:** `500`
  * **If any error occurs:**
  * **Content:**
```json
{
   "success": false,
   "message": "Failed to create due to .....",
   "status": 500,
   "data": {}
}
```


Update Device Language

* **URL**: ``BASE_URL + /shop/api/v1/customer_devices/:id/update_language``

* **Method:** `PUT`

* **URL Params:**
* params do
        * requires :app_language, type: String
* end

* **Success Response:**
* **Code:** `201`
    * **Content:**

```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully updated",
  "data": {}
}
```

* ** Error Response:*
* **Code:** `404`
    * **If customer_device is not found:**
    * **Content:**
```json
{
  "success": false,
  "status": 404,
  "message": "CustomerDevice not found",
  "data": {}
}
```

* **Code:** `500`
    * **If any error occurs:**
    * **Content:**
```json
{
  "success": false,
  "message": "Failed to update device due to ....",
  "status_code": 500,
  "data": {}
}
```

Assign User to Device

* **URL**: ``BASE_URL + /shop/api/v1/customer_devices/:id/assign_user``

* **Method:** `PUT`
* **Authorization:** `user_auth`

* **URL Params:**


* **Success Response:**
* **Code:** `201`
    * **Content:**

```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully updated",
  "data": {}
}
```

* ** Error Response:*
* **Code:** `404`
    * **If customer_device is not found:**
    * **Content:**
```json
{
  "success": false,
  "status": 404,
  "message": "CustomerDevice not found",
  "data": {}
}
```

* **Code:** `404`
    * **If user is not found:**
    * **Content:**
```json
{
  "success": false,
  "status": 404,
  "message": "User not found",
  "data": {}
}
```

* ** Error Response:*
* **Code:** `500`
    * **If any error occurs:**
    * **Content:**
```json
{
   "success": false,
   "message": "Failed to update device due to ....",
   "status_code": 500,
   "data": {}
}
```

