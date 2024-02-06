**Customer Order APIs**
----

### Customer Orders List

* **URL :** `BASE_URL + /distributors/api/v1/customer_orders`
* **Method :** `GET`

* **URL Params :**

`All params are optional here`

```json
{
  "start_date_time": "2022-01-01",
  "end_date_time": "2022-07-01",
  "order_id": 29756,
  "return_type": "",
  "shipping_type": "",
  "status": ""
}
```

* **Success Response**
    * **Code :**`200`
    * **Content :**

```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched customer list",
  "data": [
    {
      "order_id": 29756,
      "status": "Completed",
      "status_type": "completed",
      "shipping_type": "pick_up_point",
      "order_type": "induced",
      "price": "740.0",
      "warehouse_name": "Khulna FC",
      "date": "2022-01-09T18:41:09.230+06:00"
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
  "message": "Unable to fetch customer orders",
  "data": {}
}
```

### Customer Order Details

* **URL :** `BASE_URL + /distributors/api/v1/customer_orders/:id`

* **Method :** `GET`

* **URL Params :**

* **Success Response**
    * **Code :**`200`
    * **Content :**

```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched customer order details",
  "data": {
    "order_id": 108649,
    "shipping_address": {
      "area": "Bagerhat Busstand",
      "thana": "Bagerhat",
      "district": "Bagerhat",
      "phone": "01934806710",
      "address_line": "Holding # 312 Bagerhat Bus Stand, Bagerhat\n"
    },
    "billing_address": {
      "area": "Bagerhat Busstand",
      "thana": "Bagerhat",
      "district": "Bagerhat",
      "phone": "01934806710",
      "address_line": "Holding # 312 Bagerhat Bus Stand, Bagerhat\n"
    },
    "order_type": "induced",
    "pay_type": "Cash on delivery",
    "sub_total": "315.0",
    "shipping_charge": "0.0",
    "grand_total": "315.0",
    "total_discount_amount": "0.0",
    "order_at": "2022-07-03T09:08:37.867+06:00",
    "rider": {},
    "shopoth_line_items": [
      {
        "shopoth_line_item_id": 170995,
        "quantity": 1,
        "amount": "315.0",
        "sub_total": "315.0",
        "item": {
          "product_title": "FOGG Master Series Body Spray Pine 120ml",
          "sku": "D-29-B078-Fog-000828",
          "variant_id": 343,
          "unit_price": "315.0",
          "product_discount": "0.0",
          "product_attribute_values": []
        },
        "locations": [
          {
            "id": 79,
            "code": "RE-01-B-C-304",
            "quantity": 1
          }
        ]
      }
    ],
    "customer": {
      "name": "md asadul",
      "phone": "01635468617",
      "email": null
    },
    "status": "Order Placed",
    "status_key": "order_placed",
    "pay_status": "non_extended",
    "shipping_type": "Pick up point",
    "partner": {
      "name": "Ujjal Store 2",
      "distributor_name": "Rafiq Enterprise",
      "phone": "01934806710",
      "email": null,
      "route_id": 62,
      "area": null,
      "section": "B"
    },
    "is_customer_paid": false,
    "receiver_info": {
      "name": "md asadul",
      "phone": "01635468617"
    },
    "vat_shipping_charge": "0.0",
    "warehouse_name": "Khulna FC",
    "distributor_name": "Rafiq Enterprise"
  }
}
```

* **Error Response**
    * **Example-1 :**
        * **Code :** `404`
        * **Content :**

```json
{
  "success": false,
  "status": 404,
  "message": "Customer order not found",
  "data": {}
}
```

*
    * **Example-2 :**
    * **Code :** `422`
    * **Content :**

```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch customer order details",
  "data": {}
}
```

### Assign rider to customer_orders for DH Panel

* **URL :** `BASE_URL + /distributors/api/v1/customer_orders/:id/assign_rider`

* **Method :** `GET`

* **URL Params :**

```json
{
  "rider_id": 12
}
```

* **Success Response**
    * **Code :**`200`
    * **Content :**

```json
{
  "success": true,
  "status": 200,
  "message": "Rider assigned successfully.",
  "data": {}
}
```

* **Error Response**
    * **Code :** `200`
    * **Content :**

```json
{
  "success": false,
  "status": 422,
  "message": "Unable to assign rider to this order.",
  "data": {}
}
```
