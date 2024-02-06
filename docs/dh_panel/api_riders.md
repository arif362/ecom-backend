**Rider APIs**
----

##### Rider list show on distributor panel:

* **URL**: `BASE_URL + /distributor/api/v1/riders

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched riders.",
  "data": [
    {
      "id": 1,
      "name": "Ridwan Zaman",
      "phone": "01682228823",
      "email": "",
      "warehouse_id": 6,
      "collected": "0.0",
      "total_order": 0,
      "prepaid_order_count": 0
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
  "message": "Unable to fetch rider list.",
  "data": {}
}
```

##### Get a specific rider details for DH panel reconciliation:

* **URL**: `BASE_URL + /distributor/api/v1/riders/:id

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched rider details.",
  "data": {
    "name": "Ridwan Zaman",
    "phone": "01682228823"
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
  "message": "Unable to fetch rider details.",
  "data": {}
}
```

##### Get reconcile riders on distributor panel:

* **URL**: `BASE_URL + /distributor/api/v1/riders/reconcile

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched riders.",
  "data": [
    {
      "id": 1,
      "name": "Ridwan Zaman",
      "phone": "01682228823",
      "email": "",
      "warehouse_id": 6,
      "collected": "0.0",
      "total_order": 0,
      "prepaid_order_count": 0
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
  "message": "Unable to fetch rider list.",
  "data": {}
}
```

##### Get a specific Rider details on distributor panel:

* **URL**: `BASE_URL + /distributor/api/v1/riders/:id

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched rider details.",
  "data": {
    "id": 1,
    "distributor_id": 2,
    "name": "A random rider.",
    "email": "demo@dh.com",
    "phone": "01967000000"
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
  "message": "Unable to fetch rider details.",
  "data": {}
}
```

##### Get riders cash collection summary for Dh:

* **URL**: `BASE_URL + /distributor/api/v1/riders/959/cash_collection_summary

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched riders cash collection summary.",
  "data": {
    "rider_details": {
      "name": "Ridwan Zaman",
      "phone": "01682228823"
    },
    "cash_collected": {
      "rider": "0.0",
      "dh": 0
    },
    "unpacked_return": {
      "rider": 0,
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
  "message": "Unable to fetch riders cash collection summary.",
  "data": {}
}
```

##### Get rider's cash collected orders on DH panel:

* **URL**: `BASE_URL + /distributor/api/v1/riders/144/cash_collected_orders

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched rider's cash collected orders.",
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
  "message": "Unable to fetch rider's cash collected orders.",
  "data": {}
}
```

##### Get rider's return_customer_orders on DH panel:

* **URL**: `BASE_URL + /distributor/api/v1/riders/144/return_requests

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched rider's return_customer_orders.",
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
  "message": "Unable to fetch rider's return_customer_orders.",
  "data": {}
}
```

##### Get rider's customer_orders that are returned on DH panel:

* **URL**: `BASE_URL + /distributor/api/v1/riders/144/returned_orders

* **Method:** `GET`

* **URL Params:**

 ```json
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched rider's customer_orders.",
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
  "message": "Unable to fetch rider's customer_orders.",
  "data": {}
}
```

##### Receive Return Customer Order from Rider:

* **URL :** `BASE_URL + /distributors/api/v1/riders/receive_return_order/:id`

* **Method :** `PUT`

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
  "message": "Successfully received.",
  "data": true
}
```

* **Error Response**
    * Example - 1:
        * **Code :**`422`
        * **Content :**

```json
{
  "success": false,
  "status": 422,
  "message": "Unable to receive",
  "data": {}
}
```

* Example - 2:
    * **Code :**`406`
    * **Content :**

```json
{
  "success": false,
  "status": 406,
  "message": "Can not be received",
  "data": {}
}
```

##### Collect payment of customer orders of riders on DH panel:

* **URL**: `BASE_URL + /distributor/api/v1/riders/144/cash_receive

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
