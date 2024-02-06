### Show Details of One Order for rider
___
* **URL :** `BASE_URL + /rider/api/v1/customer_orders/:id/details`
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
  "order_id": 6173,
  "shipping_address": {
    "area": "th-3 area-1",
    "thana": "Kahalu",
    "district": "Narshingdi",
    "phone": "0162xxxxxxx"
  },
  "billing_address": {
    "area": "th-3 area-1",
    "thana": "Kahalu",
    "district": "Narshingdi",
    "phone": "0162xxxxxxx"
  },
  "order_type": "induced",
  "pay_type": "cash_on_delivery",
  "sub_total": "24000.0",
  "shipping_charge": "0.0",
  "grand_total": "24000.0",
  "total_discount_amount": "0.0",
  "order_at": "2022-12-26T10:43:48.727+06:00",
  "shopoth_line_items": [
    {
      "shopoth_line_item_id": 15448,
      "quantity": 6,
      "amount": "27000.0",
      "sub_total": "24000.0",
      "item": {
        "product_title": "Kitkat",
        "sku": "kitkat",
        "variant_id": 2954,
        "unit_price": "4500.0",
        "product_discount": "3000.0",
        "product_attribute_values": []
      },
      "locations": [
        {
          "id": 44,
          "code": "himi DH",
          "quantity": 256
        },
        {
          "id": 45,
          "code": "sumaya DH",
          "quantity": 9075
        }
      ]
    }
  ],
  "customer": {
    "name": "Honda Seller Storeeee",
    "phone": "0162xxxxxx",
    "email": "hondaseller@gmail.com"
  },
  "status": "order_placed",
  "partner": {
    "name": "Honda Seller Storeeee",
    "phone": "0162xxxxxxx",
    "email": "hondaseller@gmail.com",
    "route_id": 106,
    "area": null
  },
  "vat_shipping_charge": "0.0"
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
    "#{error_message}"
```
### Get PIN code of CustomerOrder for rider
___
* **URL :** `BASE_URL + /rider/api/v1/customer_orders/:id/pin`
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
  "pin": "#{order.pin}"
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
    "#{error_message}"
```
### Resend PIN code to customer
___
* **URL :** `BASE_URL + /rider/api/v1/customer_orders/:id/resend_pin`
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
  "message": "PIN sent successfully",
  "status_code": 200
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
    "#{error_message}"
```
