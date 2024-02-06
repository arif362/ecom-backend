### Feedbacks List
___

* **URL :** `BASE_URL + /api/v1/feedbacks`
* **Method :** `GET`
* **Header :** `Auth-token`
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
  "message": "Successfully fetched",
  "data": [
    {
      "id": 23,
      "message": "Shopoth User Message",
      "rating": 2,
      "user_id": 418,
      "user_name": "ra update",
      "user_phone": "018xxxxx"
    },
    {
      "id": 22,
      "message": "jjij",
      "rating": 5,
      "user_id": 323,
      "user_name": "Hum",
      "user_phone": "0162xxxxxxx"
    }
  ]
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "success": false,
  "status": 422,
  "message": "Failed to fetch feedbacks",
  "data": {}
}
```
