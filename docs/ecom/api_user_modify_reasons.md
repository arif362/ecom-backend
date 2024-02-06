### User Modify Reasons List
___

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
  "message": "Successfully fetched reason list",
  "data": {
    "deactivation_note": {
      "body": "",
      "bn_body": ""
    },
    "reason": [
      {
        "id": 1,
        "title": "Reason 1",
        "title_bn": "কারণ 1"
      }
    ]
  }
}

```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Failed to fetch",
   "data": {}
}
```


