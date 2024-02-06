### Create message
___

* **URL :** `BASE_URL + /shop/api/v1/contact_us`
* **Method :** `POST`
* **URL Params :**

```json
{
  "name": "Shopoth User",
  "phone": "01823123456",
  "email": "user@shopoth.com",
  "message": "Greetings"
}
```
* **Success Response**
 * **Code :**`201`
 * **Content :**
```json
{
  "success": true,
  "status": 201,
  "message": "Successfully sent",
  "data": {}
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Failed to send message",
   "data": {}
}
```


