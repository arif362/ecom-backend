**Aggregate Return API's**
----
***Fetch Return from Customers:***

* **URL:** `BASE_URL + /api/v1/aggregate_returns

* **Method:** `GET`

* **URL Params:**
  `{
  "start_date_time": 2021-12-27,
  "end_date_time": 2022-12-27,
  "per_page": 15,
  "page": 1,
  "order_id": 1,
  }
  `


* **Success Response:**
 ```json
[
  {
    "id": 485,
    "customer_order_id": 4197,
    "refunded": true,
    "sub_total": "200.0",
    "grand_total": "200.0",
    "order_type": "organic",
    "customer_name": "",
    "pick_up_charge": "0.0",
    "warehouse_id": 8,
    "warehouse_name": "Narshingdi",
    "requested_on": "2022-01-16T17:45:40.778+06:00",
    "return_items_count": 1
  }
]
```
### Aggregate Return Details
___

* **URL :** `BASE_URL + /api/v1/aggregate_returns/:id`

* **Method :** `GET`

* **URL Params :**

```json
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
    "pick_up_type": "from_home",
    "pick_up_charge": "40.0",
    "vat_shipping_charge": "6.0",
    "coupon_code": "FDTA5QAS",
    "reschedulable": false,
    "reschedule_date": null,
    "warehouse_id": 8,
    "warehouse_name": "Narshingdi",
    "distributor_name": "Himi Distributor",
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
   "message": "Can not fetch due to, #{error_message}",
   "data": {}
}
```


