### Customer Order List
___

* **URL :** `BASE_URL + /api/v1/customer_orders/list`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "status": "Order Placed",
  "start_date_time": "2022-11-28",
  "end_date_time": "2022-12-27"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "order_id":6154,
    "status":"Order placed",
    "status_type":"order_placed",
    "shipping_type":"Home Delivery",
    "order_type":"organic",
    "price":"4965.0",
    "warehouse_name":"Narshingdi",
    "distributor_name":"Virtual Distributor",
    "date":"2022-12-19T12:38:09.678+06:00",
    "prev_status":null,
    "business_type":"b2c"
  },
  {
    "order_id":6153,
    "status":"Order placed",
    "status_type":"order_placed",
    "shipping_type":"Home Delivery",
    "order_type":"organic",
    "price":"4965.0",
    "warehouse_name":"Narshingdi",
    "distributor_name":"Virtual Distributor",
    "date":"2022-12-19T12:36:53.745+06:00",
    "prev_status":null,
    "business_type":"b2c"
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
### Customer Order Details
___

* **URL :** `BASE_URL + /api/v1/customer_orders/:id`
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
  "order_id":6098,
  "shipping_address":
  {
    "area":"th-3 area-1",
    "thana":"Kahalu",
    "district":"Narshingdi",
    "phone":"0162xxxxxx",
    "address_line":"Kahalu, Narshingdi."
  },
  "billing_address":
    {
      "area":"th-3 area-1",
      "thana":"Kahalu",
      "district":"Narshingdi",
      "phone":"0162xxxxxx",
      "address_line":"Kahalu, Narshingdi."
    },
  "order_type":"induced",
  "pay_type":"Cash on delivery",
  "sub_total":"8000.0",
  "shipping_charge":"0.0",
  "grand_total":"4000.0",
  "total_discount_amount":"4000.0",
  "payments":[],
  "order_at":"2022-12-12T16:30:27.600+06:00",
  "rider":{},
  "shopoth_line_items":
  [
    {
      "shopoth_line_item_id":15356,
      "quantity":2,
      "amount":"9000.0",
      "sub_total":"8000.0",
      "item":
      {
        "product_title":"Kitkat",
        "sku":"kitkat",
        "variant_id":2954,
        "unit_price":"4500.0",
        "product_discount":"1000.0",
        "product_attribute_values":[]
      },
      "locations":
      [
        {
          "id":44,
          "code":"himi DH",
          "quantity":256
        },
        {
          "id":45,
          "code":"sumaya DH",
          "quantity":9075
        }
      ]
    }
  ],
  "customer":
  {
    "id":151,
    "customer_type":"Partner",
    "name":"Honda Seller Storeeee",
    "phone":"01624xxxxxx",
    "email":"hondaseller@gmail.com"
  },
  "status":"Completed",
  "status_key":"completed",
  "pay_status":"dh_received",
  "shipping_type":"Pick up point",
  "partner":
  {
    "name":"Honda Seller Storeeee",
    "phone":"0162xxxxxxx",
    "email":"hondaseller@gmail.com",
    "route_id":106,"area":null,
    "section":"D"
  },
  "is_customer_paid":true,
  "receiver_info":
  {
    "name":"Honda Seller Storeeee",
    "phone":"01624681821"
  },
  "vat_shipping_charge":"0.0",
  "warehouse_name":"Narshingdi",
  "tenure":null,
  "distributor_id":1,
  "distributor_name":"Narsingdi Distributor",
  "cancellable":false,
  "business_type":"b2b"
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to find customer order",
  "status_code": 404
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Can't show customer order details. Reason: #{error.message}",
  "status_code": 422
}
```
### Customer Order Change Log
___

* **URL :** `BASE_URL + /api/v1/customer_orders/:id/pack`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "packed_items": [
    {
      "line_item_id": 15417,
      "qr_codes": [
        "kitkat"
      ],
      "location_id": "44",
      "quantity": 1
    }
  ]
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "order_id": 6154,
  "shipping_address": {
    "area": "Noapara",
    "thana": "Bogra",
    "district": "Narshingdi",
    "phone": "+88016xxxxx",
    "address_line": "this"
  },
  "billing_address": {
    "area": "Noapara",
    "thana": "Bogra",
    "district": "Narshingdi",
    "phone": "+88016xxxxxx",
    "address_line": "this"
  },
  "order_type": "organic",
  "pay_type": "Online payment",
  "sub_total": "4850.0",
  "shipping_charge": "100.0",
  "grand_total": "4965.0",
  "total_discount_amount": "0.0",
  "payments": [],
  "order_at": "2022-12-19T12:38:09.678+06:00",
  "rider": {},
  "shopoth_line_items": [
    {
      "shopoth_line_item_id": 15417,
      "quantity": 1,
      "amount": "5000.0",
      "sub_total": "4850.0",
      "item": {
        "product_title": "Kitkat",
        "sku": "kitkat",
        "variant_id": 2954,
        "unit_price": "5000.0",
        "product_discount": "150.0",
        "product_attribute_values": []
      },
      "locations": [
        {
          "id": 44,
          "code": "himi DH",
          "quantity": 255
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
    "id": 517,
    "customer_type": "User",
    "name": "Humayra Himi",
    "phone": "016xxxxxx",
    "email": null
  },
  "status": "Ready to Ship From FC",
  "status_key": "ready_to_ship_from_fc",
  "pay_status": "customer_paid",
  "shipping_type": "Home delivery",
  "partner": {},
  "is_customer_paid": true,
  "receiver_info": {
    "name": "Humayra Himi",
    "phone": "+8801xxxxxxx1"
  },
  "vat_shipping_charge": "15.0",
  "warehouse_name": "Narshingdi",
  "tenure": null,
  "distributor_id": 10,
  "distributor_name": "Virtual Distributor",
  "cancellable": true,
  "business_type": "b2c"
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
   "success": false,
   "status": 403,
   "message": "Unable to pack due to mismatched quantity",
   "data": {}
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
   "success": false,
   "status": 403,
   "message": "Unable to pack due to unavailable quantity.",
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
   "message": "Unable to Pack order.",
   "data": {}
}
```
### Cancel Customer order from Warehouse
___

* **URL :** `BASE_URL + /api/v1/customer_orders/:id/cancel_order`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "cancellation_reason": "Not required"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": "Order Canceled!",
  "status_code": 200
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Unable to Canceled order because #{ex.message}"
}
```
### Unpack packed cancelled order
___

* **URL :** `BASE_URL + /api/v1/customer_orders/:id/unpack`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "variants_locations": [
    {
      "variant_id": 2954,
      "location_id": "44"
    }
  ]
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": "Success Order Cancelled!",
  "status_code": 200
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
   "status_code": 404,
   "message": "Customer Order not found!"
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
   "status_code": 404,
   "message": "Variant quantity mismatch!"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Unable to Unpacked order because #{ex.message}"
}
```
### Customer Order Change Log
___

* **URL :** `BASE_URL + /api/v1/customer_orders/:id/changes_log`
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
    "status": 200,
    "message": "Successfully fetched customer order changes log",
    "data": [
      {
        "id": 7241,
        "order_status": "Completed",
        "created_at": "2022-08-07T14:59:44.819+06:00",
        "changed_by": {
          "id": 133,
          "name": "Hero Honda Rider",
          "email": "herorider@gmail.com",
          "phone_number": "01817995776",
          "staffable_type": "Rider",
          "staffable_id": 133,
          "changed_by_type": "Rider"
        }
      }
    ]
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
   "success": false,
   "status": 404,
   "message": "Unable to find customer order",
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
   "message": "Unable to fetch customer order changes log",
   "data": {}
}
```

