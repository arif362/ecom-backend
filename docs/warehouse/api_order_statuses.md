### Show All Order Status
___

* **URL :** `BASE_URL + /api/v1/order_status/admin`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id":2,
    "order_type":"order_confirmed",
    "system_order_status":"Confirmed",
    "customer_order_status":"Confirmed",
    "admin_order_status":"Order Confirmed",
    "sales_representative_order_status":"Confirmed",
    "partner_order_status":"Confirmed",
    "bn_customer_order_status":"অর্ডার নিশ্চিত হয়েছে"
  },
  {
    "id":3,
    "order_type":"ready_to_shipment",
    "system_order_status":"Ready to ship",
    "customer_order_status":"Processing",
    "admin_order_status":"Ready To Shipment",
    "sales_representative_order_status":"Ready to ship",
    "partner_order_status":"Ready to ship",
    "bn_customer_order_status":"পাঠানোর জন্য প্রস্তুত"
  }
]
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "#{error_message}"
}
```
