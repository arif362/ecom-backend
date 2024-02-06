### Fetch all return orders
___
* **URL :** `BASE_URL + customer_care/api/v1/aggregate_returns`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
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
    "id":647,
   "customer_order_id":6097,
    "refunded":true,
    "sub_total":"4000.0",
    "grand_total":"4000.0",
    "order_type":"induced",
    "customer_name":"Honda Seller Storeeee",
    "pick_up_charge":"0.0",
    "warehouse_id":8,
    "warehouse_name":"Narshingdi",
    "requested_on":"2022-12-12T16:22:41.187+06:00",
    "return_items_count":1
  },
  {
    "id":646,
    "customer_order_id":6053,
    "refunded":true,
    "sub_total":"190.0",
    "grand_total":"190.0",
    "order_type":"organic",
    "customer_name":"Humayra Himi",
    "pick_up_charge":"0.0",
    "warehouse_id":8,
    "warehouse_name":"Narshingdi",
    "requested_on":"2022-12-11T13:30:05.087+06:00",
    "return_items_count":1
  }
]
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Aggregate list fetch failed for #{error.message}"
}
```
### Fetch return order details
___
* **URL :** `BASE_URL + customer_care/api/v1/aggregate_returns/:id`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "start_date_time": "2022-11-28",
  "end_date_time": "2022-12-27"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "id":647,
  "customer_order_id":6097,
  "refunded":true,
  "sub_total":"4000.0",
  "grand_total":"4000.0",
  "order_type":"induced",
  "pick_up_charge":"0.0",
  "vat_shipping_charge":"0.0",
  "pick_up_type":"to_partner",
  "reschedule_date":null,
  "coupon_code":"IXTJAD",
  "warehouse_id":8,
  "warehouse_name":"Narshingdi",
  "return_items_count":1,
  "reschedulable":false,
  "requested_on":"2022-12-12T16:22:41.187+06:00",
  "customer":
  {
    "customer_id":151,
    "customer_name":"Honda Seller Storeeee",
    "customer_phone":"0162xxxxxx"
  },
  "receiver_info":
  {
    "phone":"016xxxxxx",
    "name":"Honda Seller Storeeee"
  },
  "pick_address":
  {
    "district_id":1,
    "district_name":"Narshingdi",
    "thana_id":3,
    "thana_name":"Kahalu",
    "area_id":22,
    "area_name":"th-3 area-1",
    "address_line":"Kahalu, Narshingdi."
  },
  "rider_info":{},
  "partner_info":
  {
    "partner_id":151,
    "partner_name":"Honda Seller Storeeee",
    "partner_phone":"01xxxxxx"},
  "route_info":
  {
    "route_id":106,
    "route_name":"IT-N-303",
    "route_phone":"017xxxxx"
  },
  "return_orders":
  [
    {
      "return_order_id":1085,
      "return_status":"in_transit",
      "cancelable":false,
      "reason":"product is different from the description on the website or not as advertised",
      "return_type":"unpacked",
      "form_of_return":"to_partner",
      "requested_on":"2022-12-12T16:22:41.217+06:00",
      "quantity":1,
      "amount":"4000.0",
      "item":
      {
        "product_title":"Kitkat",
        "sku":"kitkat",
        "product_attribute_values":[]
      }
    }
  ],
  "return_quantity":1
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Can not fetch due to #{error.message}"
}
```
