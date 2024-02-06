### Partner App Notification
___

* **URL :** `BASE_URL + partner/api/v1/app_notifications`

* **Method :** `GET`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id": 6978,
    "title": "Order Placed",
    "message": "Order no 0006172 is confirmed for #{partner's_name}, phone: #{partner's_phone_number}",
    "read": true,
    "created_at": "2022-12-22 12:08:03"
  },
  {
    "id": 6977,
    "title": "Order Placed",
    "message": "Order no 0006169 is confirmed for #{partner's_name}, phone: #{partner's_phone_number}",
    "read": true,
    "created_at": "2022-12-22 11:41:52"
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
   "success": false,
   "status": 404,
   "message": "Unable to fetch notifications",
   "data": {}
}
```
