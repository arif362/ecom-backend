**DISTRIBUTOR API's**
----

### Create a distributor:

* **URL:** `BASE_URL + /api/v1/distributors

* **Method:** `POST`

* **URL Params:**

 ```json
{
  "name": "test distributor",
  "bn_name": "test distributor",
  "password": "123456",
  "password_confirmation": "123456",
  "phone": "01967579486",
  "address": "Dhaka Bangladesh",
  "code": "test-123",
  "status": "active"
}
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully created distributor.",
  "data": {}
}
```

### Update a distributor:

* **URL:** `BASE_URL + /api/v1/distributors/:id

* **Method:** `PUT`

* **URL Params:**

 ```json
{
  "name": "test distributor",
  "bn_name": "test distributor",
  "password": "123456",
  "password_confirmation": "123456",
  "phone": "01967579486",
  "address": "Dhaka Bangladesh",
  "code": "test-123",
  "status": "active"
}
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully updated distributor.",
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
          "status": 422,
          "message": "Unable to update distributor.",
          "data": {}
        }
         ```

### Get all distributors:

* **URL**: `BASE_URL + /api/v1/distributors

* **Method:** `GET`

* **URL Params:** `None`

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched distributors.",
  "data": [
    {
      "id": 1,
      "name": "Salahuddin",
      "bn_name": "rakib",
      "warehouse_id": 4,
      "email": "rakib@gmail.tech",
      "phone": "01960000000",
      "address": "Dhaka Bangladesh",
      "code": "test-123",
      "status": "active"
    }
  ]
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**
         ```json 
          {"success": false, "message": "", "status_code": , "data":   }
         ```

### Get a specific distributor details:

* **URL**: `BASE_URL + /api/v1/distributors/:id

* **Method:** `GET`

* **URL Params:** `None`

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetch distributor.",
  "data": {
    "id": 26,
    "name": "Salahuddin",
    "bn_name": "rakib",
    "warehouse_id": 4,
    "email": "rakib@misfit.tech",
    "phone": "01967579486",
    "address": "Dhaka Bangladesh",
    "code": "test-123",
    "status": "active"
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
  "message": "Unable to fetch distributor.",
  "data": {}
}
```

### Delete a distributor:

* **URL**: `BASE_URL + /api/v1/distributors/:id

* **Method:** `DELETE`

* **URL Params:** `None`

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully deleted distributor.",
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
  "message": "Unable to delete distributor.",
  "data": {}
}
```

### Distributor panel login on DH panel:

* **URL**: `BASE_URL + /distributor/api/v1/sign_in

* **Method:** `POST`

* **URL Params:**

 ```json
 {
  "email": "demo@dh.com",
  "password": "demo_password"
}
```

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully logged in.",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9.I-SPuTMP-NY",
    "staff_name": "Salahuddin",
    "warehouse_id": 4
  }
}
```

* **Error Response:**
  * **Example - 1 :**
      * **Code:** `200`
      * **Content:**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to signed_in.",
  "data": {}
}
```
*
  * **Example-2 :**
    * **Code :** `401`
    * **Content :**
```json
{
  "success": false,
  "status": 401,
  "message": "Not authorized",
  "data": {}
}
```

### Distributor logout on DH panel:

* **URL**: `BASE_URL + /distributor/api/v1/sign_out

* **Method:** `POST`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully logged out.",
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
  "message": "Logout failed.",
  "data": {}
}
```

### Partner list show on distributor panel:

* **URL**: `BASE_URL + /distributor/api/v1/partners

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched partner list.",
  "data": [
    {
      "id": 157,
      "name": "demo SR 1",
      "outlet_name": "demo SR 1",
      "route": 131,
      "distributor_name": "test distributor",
      "phone": "0176xxxxxx",
      "partner_code": "demo",
      "returns": 0,
      "total_orders": 4,
      "total_amount": "1600.0",
      "collected": "400.0",
      "due_payment": "1200.0"
    },
    {
      "id": 158,
      "name": "demo SR 1",
      "outlet_name": "demo SR 1",
      "route": 131,
      "distributor_name": "test distributor",
      "phone": "0176xxxxxxx",
      "partner_code": "demo",
      "returns": 0,
      "total_orders": 4,
      "total_amount": "1600.0",
      "collected": "400.0",
      "due_payment": "1200.0"
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
  "message": "Unable to fetch partner list.",
  "data": {}
}
```

### RA list show on DH panel:

* **URL**: `BASE_URL + /distributor/api/v1/retail_assistants

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched partner details.",
  "data": {
    "id": 157,
    "name": "demo SR 1",
    "outlet_name": "demo SR 1",
    "route": 131,
    "distributor_name": "test distributor",
    "phone": "0176xxxxxxx",
    "partner_code": "demo",
    "returns": 0,
    "total_orders": 4,
    "total_amount": "1600.0",
    "collected": "400.0",
    "due_payment": "1200.0"
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
  "message": "Unable to fetch partner details.",
  "data": {}
}
```
___

### RA list  on distributor panel

* **URL**: `BASE_URL + /distributors/api/v1/retailer_assistants`

* **Method:** `GET`

* **URL Params:**

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched retailer assistant list.",
  "data": [
    {
      "id": 65,
      "name": "ssfsfsf",
      "phone": "01727212199",
      "email": "iuwyiruwyri@hdh",
      "status": "active",
      "category": "dedicated"
    },
    {
      "id": 66,
      "name": "ssfsfsf",
      "phone": "01727212199",
      "email": "iuwyiruwyri@hdh",
      "status": "active",
      "category": "dedicated"
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
  "message": "Unable to fetch retail_assistants list.",
  "data": {}
}
```

### RA details on distributor panel

* **URL**: `BASE_URL + /distributors/api/v1/retailer_assistants/:id`

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched retail_assistant details.",
  "data": {
    "id": 1,
    "name": "RA1",
    "phone": "01857123456",
    "email": null,
    "father_name": null,
    "experience": null,
    "education": null,
    "category": "dedicated",
    "nid": null,
    "tech_skill": null,
    "date_of_birth": null,
    "address": {
      "address_line": "Area-1 block-A",
      "area_id": 1,
      "area_name": "block-c",
      "thana_id": 1,
      "thana_name": "Pallabi",
      "district_id": 1,
      "district_name": "Dhaka"
    },
    "status": "active"
  }
}
```

* **Error Response:**
  * **Example-1 :**
    * **Code :** `404`
    * **Content :**
```json
{
"success": false,
"status": 404,
"message": "Retailer assistant not Found",
"data": {}
}
```
*
  * **Example-2 :**
      * **Code :** `422`
      * **Content :**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch retail_assistant details.",
  "data": {}
}
```

### Get distributors reconciliation summary on DH panel:

* **URL**: `BASE_URL + /distributor/api/v1/balance

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched reconciliation summary.",
  "data": {
    "warehouse_cash_collected": "0.0",
    "warehouse_collectable": "0.0",
    "total_returned_request": 0,
    "total_return_collectable": 0
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
  "message": "Unable to fetch reconciliation summary.",
  "data": {}
}
```

## Routes for DH
___
#### Routes List
* **URL :** `BASE_URL + /distributors/api/v1/routes`

* **Method :** `GET`

* **URL Params :**

```json
```
* **Success Response**
  * **Code :**`200`
  * **Content :**
```json
{
    "success": true,
    "status": 200,
    "message": "Successfully fetched routes",
    "data": [
        {
            "id": 1,
            "title": "route1 dh1",
            "sr_name": "sr1",
            "sr_point": "sr1-route1-dh1",
            "bn_title": "রুট1 DH1",
            "phone": "01857123456",
            "cash_amount": "0.0",
            "total_order": 0,
            "due": 0,
            "distributor_name": "test dwh dh1",
            "distributor_bn_name": "পরীক্ষা dwh dh1"
        }
    ]
}
```
* **Error Response**
  * **Code :**``
  * **Content :**
```json
```

