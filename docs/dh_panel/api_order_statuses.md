### Order Status List
___

* **URL :** `BASE_URL + /distributors/api/v1/order_status/admin`

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
  "message": "Successfully fetched order status list",
  "data": [
    {
      "id": 1,
      "order_type": "order_placed",
      "system_order_status": "order_order_placed",
      "customer_order_status": "order_order_placed",
      "admin_order_status": "order_order_placed",
      "sales_representative_order_status": "order_order_placed",
      "partner_order_status": "order_order_placed",
      "bn_customer_order_status": ""
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
   "message": "Unable to fetch order status list",
   "data": {}
}
```


