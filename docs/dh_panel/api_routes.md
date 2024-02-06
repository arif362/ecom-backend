**Route APIs**
----

***Get Route list on distributor panel:***

* **URL**: `BASE_URL + /distributor/api/v1/routes

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched routes.",
  "data": [
    {
      "id": 959,
      "title": "AS-S-10",
      "phone": "01957200693",
      "distributor_name": "Salahuddin"
    },
    {
      "id": 1,
      "title": "RE-D-101",
      "phone": "01755622017",
      "distributor_name": "Salahuddin"
    }
  ]
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch routes.",
  "data": {}
}
```

***Get reconcile routes on DH panel:***

* **URL**: `BASE_URL + /distributor/api/v1/routes/reconcile

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched routes.",
  "data": [
    {
      "id": 959,
      "title": "AS-S-10",
      "sr_name": "SR-10",
      "sr_point": "Savar",
      "bn_title": "AS-S-10",
      "phone": "01957200693",
      "prepaid_order_count": 0,
      "total_order": 0,
      "collected_by_sr": "0.0",
      "collected_by_fc": "0.0",
      "distributor_name": "Salahuddin"
    },
    {
      "id": 1,
      "title": "RE-D-101",
      "sr_name": "Md Raju",
      "sr_point": "Dumuria",
      "bn_title": "RE-D-101",
      "phone": "01755622017",
      "prepaid_order_count": 0,
      "total_order": 0,
      "collected_by_sr": "0.0",
      "collected_by_fc": "0.0",
      "distributor_name": "Salahuddin"
    }
  ]
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch routes.",
  "data": {}
}
```

***Get a specific route details on DH panel:***

* **URL**: `BASE_URL + /distributor/api/v1/routes/959

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched route details.",
  "data": {
    "id": 959,
    "title": "AS-S-10",
    "bn_title": "AS-S-10",
    "phone": "01957200693",
    "sr_name": "SR-10",
    "sr_point": "Savar",
    "route_device": {},
    "distributor_id": 26,
    "distributor_name": "Salahuddin rakib",
    "distributor_bn_name": "rakib"
  }
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch route details.",
  "data": {}
}
```

***Get routes cash collection summary for Dh:***

* **URL**: `BASE_URL + /distributor/api/v1/routes/959/cash_collection_summary

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched routes cash collection summary.",
  "data": {
    "route_details": {
      "title": "AS-S-10",
      "phone": "01957200693"
    },
    "cash_collected": {
      "route": "0.0",
      "dh": 0
    },
    "packed_return": {
      "route": 0,
      "dh": 0
    },
    "unpacked_return": {
      "route": 0,
      "dh": 0
    }
  }
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch routes cash collection summary.",
  "data": {}
}
```

***Get route's cash collected orders on DH panel:***

* **URL**: `BASE_URL + /distributor/api/v1/routes/144/cash_collected_orders

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched route's cash collected orders.",
  "data": [
    {
      "id": 63569,
      "delivery_date": "2022-05-16T16:32:46.392+06:00",
      "order_date": "2022-05-15T11:39:37.570+06:00",
      "total_amount": "912.0",
      "collected_by_route": "912.0",
      "collected_by_dh": "0.0",
      "payment_type": "cash_on_delivery"
    }
  ]
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch route's cash collected orders.",
  "data": {}
}
```

***Get route's return_customer_orders on DH panel:***

* **URL**: `BASE_URL + /distributor/api/v1/routes/144/return_requests

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched route's return_customer_orders.",
  "data": [
    {
      "return_id": 890,
      "customer_order_id": 5275,
      "return_type": "unpacked",
      "return_status": "completed",
      "product_details": {
        "line_item_id": 13907,
        "category_id": 336,
        "title": "Hero Honda Variable Product",
        "sku": "herorm",
        "price": "500.0",
        "product_attribute_values": [
          {
            "id": 118,
            "name": "color",
            "value": "red"
          }
        ]
      },
      "receiver_type": "Route",
      "available_in_locations": [
        {
          "id": 70,
          "code": "l-b-w-unilive",
          "quantity": 2234
        }
      ]
    }
  ]
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch route's return_customer_orders.",
  "data": {}
}
```

***Get route's customer_orders that are returned on DH panel:***

* **URL**: `BASE_URL + /distributor/api/v1/routes/144/returned_orders

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched route's customer_orders.",
  "data": [
    {
      "order_id": 2688,
      "status": "In transit cancelled",
      "status_type": "in_transit_cancelled",
      "shipping_type": "pick_up_point",
      "order_type": "induced",
      "price": "450.0",
      "warehouse_name": "Narshingdi",
      "distributor_name": "test distributor moshiur",
      "date": "2021-05-30T17:42:17.535+06:00",
      "prev_status": "In transit"
    }
  ]
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch route's customer_orders.",
  "data": {}
}
```

***Get route details and it's partner margins:***

* **URL**: `BASE_URL + /distributor/api/v1/routes/144/partner_margins

* **Method:** `GET`

* **URL Params:**

 ```json
{
  "month": 5,
  "year": 2022,
  "partner_schedule": "sat_sun_mon_tues_wed_thurs"
}
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched partner margins.",
  "data": {
    "id": 144,
    "title": "Central_Office_Pickup",
    "phone": "0138146134",
    "sr_name": "Robot",
    "distributor_name": "Salahuddin rakib",
    "sr_point": "Central warehouse",
    "pay_status": "pending",
    "partner_info": {
      "total_payment": "0.0",
      "details_list": [
        {
          "id": 552,
          "name": "Members Only FC",
          "phone": "01738146134",
          "order_count": 58,
          "margin_amount": "0.0",
          "margin_received_by_partner": false
        }
      ]
    }
  }
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch partner margins.",
  "data": {}
}
```

##### Collect payment of customer orders of routes on DH panel:

* **URL**: `BASE_URL + /distributor/api/v1/routes/144/cash_receive

* **Method:** `POST`

* **URL Params:**

 ```json
{
  "start_date_time": "2022-05-12(optional)",
  "end_date_time": "2022-05-12(optional)"
}
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Customer order payments received successfully.",
  "data": {}
}
```

* **Error Response:**
* **Code:** `200`
* **Content:**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to receive customer order payments.",
  "data": {}
}
```
