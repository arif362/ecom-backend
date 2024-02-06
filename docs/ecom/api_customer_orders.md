### Create Order with Cart Items:

* **URL**: `BASE_URL + /shop/api/v1/customer_orders`
* **Method:** `POST`
* **Headers:** `User auth`
* **URL Params:**
```json
{
  "cart_id": 11034,
  "shipping_type": "pick_up_point",
  "full_name": "shopoth user",
  "phone": "01857123456",
  "new_address": {
    "district_id": 3,
    "thana_id": 34,
    "area_id": 23,
    "full_name": "",
    "phone": "",
    "home_address": "",
    "alternative_phone": "",
    "post_code": 1234,
    "title": "",
    "remember": true
  },
  
  "partner_id": 157,
  "billing_address_id": 26,
  "shipping_address_id": 78,
  "form_of_payment": "cash_on_delivery",
  "domain": "",
  "customer_device_id": 34,
  "tenure": 9
}
```


* **Success Response:**
* **Code:** `200`
    * **Content:**

```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully created customer order.",
  "data": {
    "id": 6158,
    "pay_type": "cash_on_delivery",
    "total_price": "4365.0"
}
```
* ** Error Response:**
* **Code:** `422`
* ** If Cart value less than 180tk
    * **Content:**
```json
{
  "success": false,
  "status": 406,
  "message": "Cart value must be greater or equal to 180tk",
  "data": {}
}
```

* ** Error Response:**
* **Code:** `406`
* ** If any product count is zero in cart
    * **Content:**
```json
{
  "success": false,
  "status": 406,
  "message": "Please provide valid quantity",
  "data": {}
}
```
* ** Error Response:**
* **Code:** `406`
* ** If products are unavailable
  * **Content:**
```json
{
  "success": false,
  "status": 406,
  "message": "{product1, product2, ..}** are stock out!",
  "data": {}
}
```
* ** Error Response:**
* **Code:** `422`
* ** If any other error occurs
  * **Content:**
```json
{
  "success": false,
  "status": 422,
  "message": "Unable to create customer orders",
  "data": {}
}
```
### Show logged in user's customer orders
___

* **URL :** `BASE_URL + /shop/api/v1/customer_orders/my-orders`
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
  "message": "Order fetch successfully.",
  "data": [
    {
      "order_id": "0005987",
      "ordered_on": "2022-11-23T19:23:51.137+06:00",
      "delivered_on": "2022-11-26T19:23:51.137+06:00",
      "status": "Order Placed",
      "status_key": "order_placed",
      "bn_status": "অর্ডার প্লেস হয়েছে",
      "vat_shipping_charge": "0.0",
      "total": 4555,
      "is_returnable": false,
      "returnable_date": ""
    },
    {
      "order_id": "0005909",
      "ordered_on": "2022-11-13T16:03:52.187+06:00",
      "delivered_on": "2022-11-16T16:03:52.187+06:00",
      "status": "Cancelled",
      "status_key": "packed_cancelled",
      "bn_status": "ক্যান্সেল করা হয়েছে",
      "vat_shipping_charge": "0.0",
      "total": 4450,
      "is_returnable": false,
      "returnable_date": ""
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
### Show Details of One Customer Order
___

* **URL :** `BASE_URL + /shop/api/v1/customer_orders/:id`
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
  "message": "Order fetch successfully.",
  "data": {
    "order_id": 6158,
    "shipping_charge": "0.0",
    "total_discount_amount": "485.0",
    "shipping_type": "pick_up_point",
    "order_type": "organic",
    "pay_type": "cash_on_delivery",
    "trx_id": "",
    "total_price": "4850.0",
    "vat_shipping_charge": "0.0",
    "total_payable": "4365.0",
    "partner_id": 157,
    "partner_name": "Shopoth Partner 1",
    "partner_code": "RASR1",
    "created_at": "2022-12-20T12:48:44.182+06:00",
    "completed_at": "",
    "recipient_name": "ra",
    "recipient_phone": "01857123456",
    "customer_name": "ra",
    "customer_phone": "0185xxxxxxx",
    "is_returnable": false,
    "return_charge": 0.0,
    "returnable_date": "",
    "status": "Order Placed",
    "status_key": "order_placed",
    "bn_status": "",
    "return_vat_shipping_charge": 0,
    "shipping_address": {
      "id": 2957,
      "address_title": "others",
      "name": "Shopoth Partner 1",
      "bn_name": "",
      "phone": "0176xxxxxx",
      "district_id": 1,
      "thana_id": 4,
      "area_id": 14,
      "district_name": "Narshingdi",
      "district_bn_name": "Narshingdi",
      "thana_name": "Abhaynagar",
      "thana_bn_name": "অভয়নগর",
      "area_name": "Bogra",
      "area_bn_name": "Local Brand",
      "address_line": "RA SR 1",
      "bn_address_line": "",
      "zip_code": ""
    },
    "shopoth_line_items": [
      {
        "id": 15422,
        "quantity": 1,
        "price": "5000.0",
        "unit_price": 4850,
        "sub_total": 4850,
        "discount_amount": 150,
        "sample_for": "",
        "returned_quantity": 0,
        "refundable": true,
        "returnable": true,
        "variant_id": 2954,
        "product_id": 3860,
        "product_title": "Kitkat",
        "product_bn_title": "কিটকেট",
        "max_quantity_per_order": 0,
        "product_slug": "শীর্ষ-খবর",
        "product_image": "http://cdn.shopoth.net/wzsq3qjcfhfog8ux4isks4dgq5y0",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": false,
        "is_limit_exceeded": false
      }
    ],
    "tenure": ""
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
   "message": "Order fetch failed",
   "data": {}
}
```


