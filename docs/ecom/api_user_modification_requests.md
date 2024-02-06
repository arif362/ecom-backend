**User Account Modification Request API's**
----
### Send Request List

* **URL**: ``BASE_URL + shop/api/v1/account_requests``
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
  "message": "Successfully Fetch Send Request List",
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


### Send Account Modification Request
* **URL**: ``BASE_URL + shop/api/v1/account_requests``
* **Method:** `POST`
* **URL Params:**
```
params do
  requires :request_type, type: String, values: %w[deactivated deleted]
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
  "message": "Successfully Send Request",
  "data": {
    "request_type": "deactivated",
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
  "message": "Failed to send request",
  "data": {}
}
```
### Account Modification Reason list
* **URL :** `BASE_URL + shop/api/v1/modify_reasons`

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
  "message": "Successfully fetched reasons",
  "data": {
          "deactivation_note": {
          "body": "This is a note",
          "bn_body": "এটি একটি নোট"
          },
         "reasons":  [
               {
                "id": 1,
                "title": "Reason 1",
                "title_bn": "কারণ 1",
              },
              {
                "id": 2,
                "title": "Reason 1",
                "title_bn": "কারণ 1",
              }
         ]
       }
```
* ** Error Response:**
* **Code:** `422`
  * **Content:**
```json
{
  "success": false,
  "status": 422,
  "message": "Failed to fetch reasons",
  "data": {}
}
```
