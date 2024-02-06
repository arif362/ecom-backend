### Order list
___

* **URL :** `BASE_URL + /shop/api/v1/order_trackings`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
 * **Code :**`201`
 * **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Order fetch successfully.",
  "data": [
    {
      "order_id": "0006158",
      "ordered_on": "2022-12-20T12:48:44.182+06:00",
      "delivered_on": "2022-12-23T12:48:44.182+06:00",
      "status": "Order Placed",
      "bn_status": "অর্ডার প্লেস হয়েছে",
      "order_type": "organic",
      "shipping_type": "pick_up_point",
      "total": 4365,
      "order_track": [
        {
          "position": 0,
          "status": "Order Placed",
          "bn_status": "অর্ডার প্লেস হয়েছে",
          "location": "Warehouse",
          "bn_location": "ওয়্যারহাউস",
          "date_time": "2022-12-20T12:48:44.182+06:00",
          "is_complete": true,
          "status_key": "order_placed"
        },
        {
          "position": 4611686018427387903,
          "status": "Processing",
          "bn_status": "প্রসেস করা হচ্ছে",
          "location": "Warehouse",
          "bn_location": "ওয়্যারহাউস",
          "date_time": "",
          "is_complete": false,
          "status_key": "ready_to_ship_from_fc"
        }
      ]
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
   "message": "Order fetch failed",
   "data": {}
}
```
