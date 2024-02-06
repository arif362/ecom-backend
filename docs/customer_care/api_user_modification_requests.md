**User Account Modification Request API's**
----
### User Request List

* **URL**: ``BASE_URL + customer_care/api/v1/account_requests``
* **Method:** `GET`
* **URL Params:**
```
params do
  optional :user_id, type: Integer
  optional :status, type: Integer, values: ["pending", "approved", "rejected"]
end
```

* **Success Response:**
* **Code:** `200`
  * **Content:**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully Fetch User Request List",
  "data": [
    {
      "request_type": "activated",
      "status": "pending",
      "user_modify_reason_id": 1,
      "user_modify_reason_title": "reason 1",
      "user_modify_reason_title_bn": "reason bn 1",
      "reason": null
    },
    {
      "request_type": "activated",
      "status": "pending",
      "user_modify_reason_id": 1,
      "user_modify_reason_title": "reason 1",
      "user_modify_reason_title_bn": "reason bn 1",
      "reason": null
    }
  ]
}
```
* ** Error Response:**
* **Code:** `200`
  * **Content:**
```json
{
  "success": false,
  "status": 422,
  "message": "Failed to fetch",
  "data": []
}
```
----


### User Request Details
* **URL**: ``BASE_URL + customer_care/api/v1/account_requests/:id``
* **Method:** `GET`
* **URL Params:**
```
```

* **Success Response:**
* **Code:** `200`
  * **Content:**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully Fetch User Request Details",
  "data": {
    "id": 4,
    "request_type": "deactivated",
    "user_id": 336,
    "user_name": "Moshiur Rahman",
    "user_phone": "01517816145",
    "user_email": "moshiur2@gmail.com",
    "user_status": "active",
    "status": "pending",
    "user_modify_reason_id": 1,
    "user_modify_reason_title": "reason 1",
    "user_modify_reason_title_bn": "reason bn 1",
    "reason": null
  }
}
```
* ** Error Response:**
* **Code:** `200`
  * **Content:**
```json
{
  "success": false,
  "status": 422,
  "message": "Failed to fetch details",
  "data": {}
}
```
----


### Create Account Modification Request
* **URL**: ``BASE_URL + customer_care/api/v1/account_requests``
* **Method:** `POST`
* **URL Params:**
```
params do
  requires :user_id, type: Integer
  requires :request_type, type: String, values: ["activated", "deactivated", "deleted"]
  requires :user_modify_reason_id, type: Integer
  optional :reason, type: String
end
```

* **Success Response:**
* **Code:** `200`
  * **Content:**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully Make Modification",
  "data": {
    "id": 4,
    "request_type": "activated",
    "user_id": 336,
    "user_name": "Moshiur Rahman",
    "user_phone": "01517816145",
    "user_email": "moshiur2@gmail.com",
    "user_status": "active",
    "status": "approved",
    "user_modify_reason_id": 1,
    "user_modify_reason_title": "reason 1",
    "user_modify_reason_title_bn": "reason bn 1",
    "reason": null
  }
}
```
* ** Error Response:**
* **Code:** `200`
  * **Content:**
```json
{
  "success": false,
  "status": 422,
  "message": "Failed to make request",
  "data": {}
}
```


### Approve User Request
* **URL**: ``BASE_URL + customer_care/api/v1/account_requests/:id/approve``
* **Method:** `PUT`
* **URL Params:**
```
```

* **Success Response:**
* **Code:** `200`
  * **Content:**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully Approved the Request",
  "data": {}
}
```
* ** Error Response:**
* **Code:** `200`
  * **Content:**
```json
{
  "success": false,
  "status": 422,
  "message": "Failed to approve the request",
  "data": {}
}
```
----

## Reject User Request
* **URL**: ``BASE_URL + customer_care/api/v1/account_requests/:id/reject``
* **Method:** `PUT`
* **URL Params:**
```
```

* **Success Response:**
* **Code:** `200`
  * **Content:**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully rejected the Request",
  "data": {}
}
```
* ** Error Response:**
* **Code:** `200`
  * **Content:**
```json
{
  "success": false,
  "status": 422,
  "message": "Failed to reject the request",
  "data": {}
}
```
----
