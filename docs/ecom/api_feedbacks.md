### Create Feedback
___

* **URL :** `BASE_URL + /shop/api/v1/feedbacks`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "message": "Shopoth User Message",
  "rating": 2
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
