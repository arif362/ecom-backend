**Return Transfer Order's API's**
----

***Get all Return Transfer Orders.***

* **URL:** `BASE_URL + /api/v1/return_transfer_orders

* **Method:** `GET`

* **URL Params:**
```json
 
```

* **Success Response:**
 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched return transfer orders.",
  "data": [
    {
      "id": 14,
      "warehouse_id": 4,
      "order_by": 0,
      "quantity": 3,
      "total_price": "5100.0",
      "order_status": "order_placed"
    }
  ]
}
```

***Get all ReturnTransferOrders for exporting.***

* **URL:** `BASE_URL + /api/v1/return_transfer_orders/export

* **Method:** `GET`

* **URL Params:**
```json
 
```

* **Success Response:**
 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched return transfer orders.",
  "data": [
    {
      "id": 14,
      "warehouse_id": 4,
      "order_by": 0,
      "quantity": 3,
      "total_price": "5100.0",
      "order_status": "order_placed"
    }
  ]
}
```

***Get details of a specific ReturnTransferOrder.***

* **URL:** `BASE_URL + api/v1/return_transfer_orders/:id

* **Method:** `GET`

* **URL Params:**
```json
 
```

* **Success Response:**
 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched return transfer orders.",
  "data": {
    "id": 14,
    "warehouse_id": 4,
    "order_by": 0,
    "quantity": 3,
    "total_price": "5100.0",
    "order_status": "order_placed",
    "line_items": [
      {
        "id": 15059,
        "return_transfer_order_id": 14,
        "received_quantity": 0,
        "qc_passed": 0,
        "quality_failed": 0,
        "quantity_failed": 0,
        "qc_status": false,
        "variant_id": 5033,
        "product_title": "Lenor - Sleeveless Jacket (Both Side Wearable) M (FF-107-S697-Len-005721)",
        "sku": "FF-107-S697-Len-005721",
        "category_id": 5,
        "price": "3400.0",
        "total_price": "6800.0",
        "quantity": 2,
        "location": null,
        "product_id": 4377,
        "code_by_supplier": "",
        "available_in_locations": [
          {
            "id": 81,
            "code": "AL-01-A-A-201",
            "quantity": 5
          }
        ]
      },
      {
        "id": 15060,
        "return_transfer_order_id": 14,
        "received_quantity": 0,
        "qc_passed": 0,
        "quality_failed": 0,
        "quantity_failed": 0,
        "qc_status": false,
        "variant_id": 5032,
        "product_title": "Lenor - Sleeveless Jacket (Both Side Wearable) S (FF-107-S697-Len-005720)",
        "sku": "FF-107-S697-Len-005720",
        "category_id": 5,
        "price": "1700.0",
        "total_price": "1700.0",
        "quantity": 1,
        "location": null,
        "product_id": 4377,
        "code_by_supplier": "",
        "available_in_locations": [
          {
            "id": 81,
            "code": "AL-01-A-A-201",
            "quantity": 2
          }
        ]
      }
    ]
  }
}
```

***Create a return transfer order.***

* **URL:** `BASE_URL + /api/v1/return_transfer_orders

* **Method:** `POST`

* **URL Params:**
```json
 {
  "return_transfer_order_params":[
    {
      "variant_id": 5033,
      "quantity": 2,
      "location_id": 81
    },
    {
      "variant_id": 5032,
      "quantity": 1,
      "location_id": 81
    }
  ]
}
```

* **Success Response:**
 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully created return transfer order.",
  "data": {}
}
```

***Create a Box for Return Transfer Order***

* **URL:** `BASE_URL + /api/v1/return_transfer_orders/boxes

* **Method:** `POST`

* **URL Params:**
* params do
  * requires :rt_order_id, type: Integer
  * requires :line_item_ids, type: Array, allow_blank: false
* end

* **Success Response:**
 ```json
{
  "message": "Successfully created box",
  "status_code": 200
}
```


***Remove Item From Box For Return Transfer Order***

* **URL:** `BASE_URL + /api/v1/return_transfer_orders/boxes/item_remove

* **Method:** `DELETE`

* **URL Params:**
* params do
  * requires :rt_order_id, type: Integer
  * requires :line_item_id, type: Integer
  * requires :box_id, type: Integer
* end

* **Success Response:**
 ```json
{
    "message": "Successfully deleted",
    "status_code": 200
}
```


***Remove Box For Return Transfer Order***

* **URL:** `BASE_URL + /api/v1/return_transfer_orders/boxes/remove

* **Method:** `DELETE`

* **URL Params:**
* params do
  * requires :rt_order_id, type: Integer
  * requires :box_id, type: Integer
* end

* **Success Response:**
 ```json
{
    "message": "Successfully deleted",
    "status_code": 200
}
```



***Move A Box To Another Box For Return Transfer Order***

* **URL:** `BASE_URL + /api/v1/return_transfer_orders/boxes/move

* **Method:** `PUT`

* **URL Params:**
* params do
  * requires :line_item_ids, type: Array, allow_blank: false
  * requires :rt_order_id, type: Integer
  * requires :box_id, type: Integer
* end

* **Success Response:**
 ```json
{
    "message": "Successfully moved",
    "status_code": 200
}
```



***Pack A Box For Return Transfer Order***

* **URL:** `BASE_URL + /api/v1/return_transfer_orders/boxes/pack

* **Method:** `PUT`

* **URL Params:**
* params do
  * requires :rt_order_id, type: Integer
  * requires :box_id, type: Integer
  * requires :line_items, type: Array do
    * requires :line_item_id, type: Integer
    * requires :location_id, type: Integer
    * requires :sku, type: String
    * requires :quantity, type: Integer
  * end
* end

* **Success Response:**
 ```json
{
    "message": "Successfully packed",
    "status_code": 200
}
```
* **Error Response:**
* *If line item given quantity not positive*
 ```json
{
  "message": "Unable to pack. reason: quantity can't be  negative",
  "status_code": 406
}
```

* **Error Response:**
* *If line item given quantity mismatch*
 ```json
{
  "message": "Unable to pack. reason: quantity can't be  negative",
  "status_code": 406
}
```



***Make Return Transfer Order In_Transit***

* **URL:** `BASE_URL + /api/v1/return_transfer_orders/:id/in_transit

* **Method:** `PUT`

* **URL Params:**

* **Success Response:**
 ```json
true
```


***Make Return Transfer Order Received_To_Wh***

* **URL:** `BASE_URL + /api/v1/return_transfer_orders/:id/received_to_wh

* **Method:** `PUT`

* **URL Params:**

* **Success Response:**
 ```json
true
```


