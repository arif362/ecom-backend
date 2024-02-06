**Return Order API's**
----
***Fetch Return from Customers:***

* **URL:** `BASE_URL + /api/v1/return_orders

* **Method:** `GET`

* **URL Params:**
  `{
  "start_date_time": 2021-12-27,
  "end_date_time": 2022-12-27,
  "per_page": 15,
  "page": 1,
  "order_id": 109,
  "distributor_id": 1,
  }
  `


* **Success Response:**
 ```json
[
  {
    "id": 807,
    "customer_order_number": null,
    "customer_id": 105,
    "customer_name": "Roksana  Akhtar",
    "shop_name": "Misfit Outlet",
    "created_at": "2022-01-10T17:36:32.466+06:00",
    "phone": "01788628782",
    "price": "2000.0",
    "return_type": "packed",
    "return_status": "in_transit",
    "customer_order_type": "organic",
    "order_id": 4132,
    "initiated_by": "Partner"
  }
]
```
### Return Order Details
___

* **URL :** `BASE_URL + /api/v1/return_orders/:id`

* **Method :** `GET`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
    "return_details": {
        "id": 895,
        "backend_id": "0000895",
        "order_id": "0005393",
        "order_backend_id": 5393,
        "date": "2022-08-08T12:10:21.443+06:00",
        "item_title": "Kitkat",
        "price": "5000.0",
        "return_status": "Qc Pending",
        "return_type": "Unpacked",
        "return_reason": "product is different from the description on the website or not as advertised",
        "description": "",
        "preferred_delivery_date": null,
        "form_of_return": "From Home",
        "return_option": "collect from home",
        "return_option_value": 0,
        "payment_type": "Cash On Delivery",
        "total_discount_amount": "0.0",
        "is_customer_paid": true,
        "distributor_name": "Himi Distributor"
    },
    "customer": {
        "id": 384,
        "name": "Tamim",
        "phone": "01633087584",
        "email": "tomcandy205@gmail.com"
    },
    "rider": {},
    "return_order_details": {
        "id": 5393,
        "sub_total": "4884.0",
        "total_discount": "0.0",
        "shipping_charge": "40.0",
        "vat_shipping_charge": "6.0",
        "total_price": "4784.0",
        "warehouse_id": 8,
        "warehouse_name": "Narshingdi",
        "shipping_address": {
            "name": "Tomas",
            "phone": "01633087584",
            "area": "multi-1 area-1",
            "thana": "multi-1 thana",
            "district": "multi-1",
            "zip_code": null
        },
        "billing_address": {
            "name": "Tomas",
            "phone": "multi-1 thana",
            "area": "multi-1 area-1",
            "thana": "multi-1 thana",
            "district": "multi-1",
            "zip_code": null
        },
        "rider_details": {
            "name": "Hero Honda Rider",
            "phone": "01817995776"
        },
        "items": [
            {
                "product_title": "Kitkat",
                "product_image": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/7bf8ecf23b2d8ff8d6adb",
                "shopoth_line_item_id": 14193,
                "quantity": 1,
                "price": "5000.0",
                "discount_amount": "116.0",
                "sub_total": "4884.0",
                "total": "4884.0",
                "item": {
                    "product_title": "Kitkat",
                    "sku": "kitkat",
                    "unit_price": "5000.0",
                    "product_attribute_values": []
                }
            }
        ],
        "returned_items": []
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
   "message": "Unable to show due to #{error_message}",
   "data": {}
}
```


