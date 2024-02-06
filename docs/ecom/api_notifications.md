### Get all notifications of the logged in user
___

* **URL :** `BASE_URL + /shop/api/v1/notifications`
* **Method :** `GET`
* **Header :** `Auth Token`
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
  "message": "Successfully fetched user notifications.",
  "data": [
    {
      "id": 20342,
      "details": "Your order (6158) is placed!",
      "bn_details": null,
      "read": true,
      "time_ago": "3 hours ago",
      "user_notifiable_id": 6158,
      "user_notifiable_type": "CustomerOrder"
    },
    {
      "id": 20200,
      "details": "Your order (5987) is placed!",
      "bn_details": null,
      "read": true,
      "time_ago": "26 days ago",
      "user_notifiable_id": 5987,
      "user_notifiable_type": "CustomerOrder"
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
   "message": "Unable to fetch notifications",
   "data": {}
}
```
### Unread notifications count
___

* **URL :** `BASE_URL + /shop/api/v1/notifications/unread_count`
* **Method :** `GET`
* **Header :** `Auth Token`
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
  "message": "Successfully counted notifications.",
  "data": {
    "count": 0
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
   "message": "Unable to count notifications",
   "data": {}
}
```
### Create a notification
___

* **URL :** `BASE_URL + /shop/api/v1/notifications`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "id": 20351,
  "details": "new notification details",
  "bn_details": null,
  "read": false,
  "time_ago": "0 seconds ago",
  "user_notifiable_id": null,
  "user_notifiable_type": null
}
```
### Notification Details
___

* **URL :** `BASE_URL + /shop/api/v1/notifications/:id`
* **Method :** `PUT`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "read": true
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "id": 20351,
  "details": "new notification details",
  "bn_details": null,
  "read": true,
  "time_ago": "0 seconds ago",
  "user_notifiable_id": null,
  "user_notifiable_type": null
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to count notifications",
   "data": {}
}
```
