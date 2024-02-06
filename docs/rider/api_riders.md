### Log a shopoth_rider
___
* **URL :** `BASE_URL + /rider/api/v1/login`
* **Method :** `POST`
* **URL Params :**

```json
{
    "phone": "018xxxxxxxx",
    "password": "123456"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "auth_token": "auth-token"
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "error": "Invalid phone or password"
}
```
### Get rider app version config
___
* **URL :** `BASE_URL + /rider/api/v1/app_config`
* **Method :** `GET`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "minimum_version": "1.0.0",
  "latest_version": "2.0.0",
  "is_android_published": false,
  "is_ios_published": false,
  "force_update": false
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Rider app version config fetch failed.",
  "status_code": 422
}
```
### Return Home_delivery_list.
___
* **URL :** `BASE_URL + /rider/api/v1/home_delivery`
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
    "order_id": 5411,
    "phone_number": "0185xxxxxxx",
    "amount": "471.0",
    "shipping_charge": "100.0",
    "total_discount_amount": "0.0",
    "order_type": "organic",
    "payment_type": "cash_on_delivery",
    "address": "12ABC",
    "status": "ready_to_shipment",
    "on_hold": false,
    "customer_name": "Shopoth User",
    "expected_delivery_time": "1660216230791"
  },
  {
    "order_id": 5483,
    "phone_number": "0185xxxxxxx",
    "amount": "315.0",
    "shipping_charge": "100.0",
    "total_discount_amount": "0.0",
    "order_type": "organic",
    "payment_type": "cash_on_delivery",
    "address": "12ABC",
    "status": "in_transit",
    "on_hold": false,
    "customer_name": "Shopoth User",
    "expected_delivery_time": "1660919236795"
  }
]
 ```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "#{error_message}",
  "status_code": 404
}
```
### Return Express_delivery_list.
___
* **URL :** `BASE_URL + /rider/api/v1/express_delivery`
* * **Header :** `Auth-token`
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
    "order_id": 3662,
    "phone_number": null,
    "amount": "2070.0",
    "shipping_charge": "70.0",
    "total_discount_amount": "0.0",
    "order_type": "organic",
    "payment_type": "cash_on_delivery",
    "address": null,
    "status": "ready_to_shipment",
    "on_hold": false,
    "customer_name": null,
    "expected_delivery_time": "1637758586460"
  },
  {
    "order_id": 3690,
    "phone_number": "01558143505",
    "amount": "2281.0",
    "shipping_charge": "70.0",
    "total_discount_amount": "0.0",
    "order_type": "organic",
    "payment_type": "cash_on_delivery",
    "address": null,
    "status": "ready_to_shipment",
    "on_hold": false,
    "customer_name": "Zannat Mumu",
    "expected_delivery_time": "1637998535980"
  }
]
 ```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "#{error_message}",
  "status_code": 404
}
```
### Rider Scan packed customer_order invoice.
___
* **URL :** `BASE_URL + /rider/api/v1/scan_product`
* **Method :** `GET`
* * **Header :** `Auth-token`
* **URL Params :**

```json
{
  "invoice_id": 5464
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "order_id": 5464,
  "phone_number": "015xxxxxxxx",
  "amount": "2281.0",
  "shipping_charge": "70.0",
  "total_discount_amount": "0.0",
  "order_type": "organic",
  "payment_type": "cash_on_delivery",
  "address": null,
  "status": "in_transit",
  "on_hold": false,
  "customer_name": "Shopoth User",
  "expected_delivery_time": "1637998535980"
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Invalid order scanned under this rider.",
  "status_code": 422
}
```
* **Error Response** (If order status is not **ready_to_shipment**)
* **Code :**`422`
* **Content :**
```json
{
  "message": "This order can't be moved to in_transit.",
  "status_code": 422
}
```
### Handover order to customer.
___
* **URL :** `BASE_URL + /rider/api/v1/product_handover`
* **Method :** `POST`
* * **Header :** `Auth-token`
* **URL Params :**

```json
{
  "order_id": 1245,
  "pin": "3456"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "order_id": 1245,
  "amount_paid": 5620,
  "pay_type": "cash_on_delivery"
}
 ```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
  "message": "Incorrect pin provided or wrong invoice",
  "status_code": 403
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
  "message": "Wrong invoice scanned",
  "status_code": 403
}
```
### Order on hold
___
* **URL :** `BASE_URL + /rider/api/v1/put_order_on_hold`
* **Method :** `POST`
* * **Header :** `Auth-token`
* **URL Params :**

```json
{
  "order_id": 1245
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "message": "Status changed from in-transit to on-hold"
}
 ```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
  "message": "Status Not Updated",
  "status_code": 403
}
```
### Reset on hold status
___
* **URL :** `BASE_URL + /rider/api/v1/reset_on_hold_status`
* **Method :** `POST`
* * **Header :** `Auth-token`
* **URL Params :**

```json
{
  "order_id": 1245
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "message": "Status changed from on-hold to in-transit"
}
 ```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
  "message": "Status Not Updated",
  "status_code": 403
}
```
### Report to Customer Care
___
* **URL :** `BASE_URL + /rider/api/v1/report_customer_care`
* **Method :** `POST`
* * **Header :** `Auth-token`
* **URL Params :**

```json
{
  "order_id": 1245,
  "report_type": "RouteDevice"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "message": "Reported"
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Something Went wrong",
  "status_code": 422
}
```
### Rider Dashboard
___
* **URL :** `BASE_URL + /rider/api/v1/dashboard`
* **Method :** `GET`
* * **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "balance": {
    "cash_balance": "32450.0"
  },
  "home_deliveries": {
    "total_orders": 5,
    "on_hold_orders": 0
  },
  "express_deliveries": {
    "total_orders": 0,
    "on_hold_orders": 0
  },
  "return_deliveries": {
    "total_orders": 0,
    "on_hold_orders": 0
  }
}
 ```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to generate dashboard due to: #{ex.message}",
  "status_code": 404
}
```
### Rider Payment History
___
* **URL :** `BASE_URL + /rider/api/v1/payment_history`
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
    "date": "30/11/2021",
    "order_list": [
      {
        "order_id": 3743,
        "customer_name": "User",
        "order_type": "organic",
        "business_type": "b2c",
        "app_order_type": "organic",
        "phone": "01xxxxxxxx",
        "amount": "2519.0",
        "area": "Bogra 00"
      },
      {
        "order_id": 3742,
        "customer_name": "User",
        "order_type": "organic",
        "business_type": "b2c",
        "app_order_type": "organic",
        "phone": "01zzzzzzz",
        "amount": "2284.0",
        "area": "Bogra 00"
      }
    ]
  }
]
 ```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to fetch payment history due to #{ex.message}",
  "status_code": 404
}
```
### Rider Reports
___
* **URL :** `BASE_URL + /rider/api/v1/reports`
* **Method :** `GET`
* * **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "delivery": {
    "total_order": 22,
    "received_from_dh": 0,
    "delivered": 0,
    "remaining": 0
  },
  "payments": {
    "customer_paid": 0.0,
    "collected_online": 0.0,
    "collected_cod": 0.0,
    "paid_to_fc": 0.0
  },
  "returns": {
    "total_requests": 0,
    "received_from_customer": 0,
    "remaining": 0
  }
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to fetch report due to #{ex.message}",
  "status_code": 422
}
```


