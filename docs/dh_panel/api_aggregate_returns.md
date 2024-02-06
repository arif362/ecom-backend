### Return Request using Aggregate Returns List
___

* **URL :** `BASE_URL + /distributors/api/v1/aggregate_returns`

* **Method :** `GET`

* **URL Params :**

```json
{
  "start_date_time": "",
  "end_date_time": ""
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
    {
        "id": 531,
        "customer_order_id": 5393,
        "refunded": true,
        "sub_total": "4884.0",
        "grand_total": "4838.0",
        "order_type": "organic",
        "customer_name": "Tamim",
        "pick_up_charge": "40.0",
        "warehouse_id": 8,
        "warehouse_name": "Narshingdi",
        "requested_on": "2022-08-08T12:10:21.437+06:00",
        "return_items_count": 1
    }
]
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch aggregate returns list",
   "data": {}
}
```

### Aggregate Returns Details
___

* **URL :** `BASE_URL + /distributors/api/v1/aggregate_returns/:id`

* **Method :** `GET`

* **URL Params :**

```json
{
  "start_date_time": "",
  "end_date_time": ""
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "id": 531,
  "customer_order_id": 5393,
  "refunded": true,
  "sub_total": "4884.0",
  "grand_total": "4838.0",
  "order_type": "organic",
  "pick_up_type": "From Home",
  "pick_up_charge": "40.0",
  "vat_shipping_charge": "6.0",
  "coupon_code": "FDTA5QAS",
  "reschedulable": false,
  "reschedule_date": null,
  "warehouse_id": 8,
  "warehouse_name": "Narshingdi",
  "return_items_count": 1,
  "requested_on": "2022-08-08T12:10:21.437+06:00",
  "customer": {
    "customer_id": 384,
    "customer_name": "Tamim",
    "customer_phone": "01633087584"
  },
  "receiver_info": {
    "phone": "01633087584",
    "name": "Tomas"
  },
  "pick_address": {
    "district_id": 6,
    "district_name": "multi-1",
    "thana_id": 35,
    "thana_name": "multi-1 thana",
    "area_id": 20,
    "area_name": "multi-1 area-1",
    "address_line": "Mia Para Road,"
  },
  "rider_info": {
    "rider_id": 133,
    "rider_name": "Hero Honda Rider",
    "rider_phone": "01817995776"
  },
  "partner_info": {},
  "route_info": {},
  "return_orders": [
    {
      "return_order_id": 895,
      "return_status": "Qc Pending",
      "reason": "product is different from the description on the website or not as advertised",
      "return_type": "Unpacked",
      "form_of_return": "From Home",
      "requested_on": "2022-08-08T12:10:21.443+06:00",
      "quantity": 1,
      "amount": "4884.0",
      "item": {
        "product_title": "Kitkat",
        "sku": "kitkat",
        "product_attribute_values": []
      }
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
   "message": "Unable to fetch aggregate return",
   "data": {}
}
```

### Aggregate Returns Assign Rider
___

* **URL :** `BASE_URL + /distributors/api/v1/aggregate_returns/:id/rider_assign`

* **Method :** `GET`

* **URL Params :**

```json
{
  "rider_id": 1
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully rider assigned",
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
  "message": "Unable to assign rider",
  "data": {}
}
```
