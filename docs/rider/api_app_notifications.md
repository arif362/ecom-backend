### Rider App Notification
___
* **URL :** `BASE_URL + /rider/api/v1/app_notifications`
* **Method :** `GET`
* * **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id": 6050,
    "message": "Order no 0005485 successfully delivered to Rukaiya amin",
    "read": true,
    "created_at": "2022-08-16T20:56:47.948+06:00",
    "title": "Order Delivered"
  },
  {
    "id": 6049,
    "message": "Received 315.0 taka in cash from User, phone: 0185xxxxxxx",
    "read": true,
    "created_at": "2022-08-16T20:56:47.943+06:00",
    "title": "Payment from Customer"
  }
]
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "error": "Unable to get notifications due to #{ex.message}"
}
```
