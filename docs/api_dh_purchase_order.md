**DhPurchaseOrder API's**
----
Create a Dh_Purchase_Order

* **URL:** `BASE_URL + /api/v1/dh_purchase_orders`

* **Method:** `POST`

*  **URL Params:**
   `{
   "supplier_id": 1,
   "warehouse_id": 1,
   "logistic_id": 1,
   "order_by": 1,
   "quantity": "120",
   "bn_quantity": "120",
   "total_price": "120000",
   "bn_total_price": "120000",
   "status": "Available",
   "bn_status": "Available" 
   }`
   
* **Success Response:**
 ```json 
 {
    "id": 1,
    "supplier_id": 1,
    "warehouse_id": 1,
    "order_by": 1,
    "quantity": "120.0",
    "bn_quantity": "120.0",
    "total_price": "120000.0",
    "bn_total_price": "120000.0",
    "status": "Available",
    "bn_status": "Available",
    "order_date": null,
    "is_deleted": false,
    "created_at": "2020-12-22T07:29:39.605Z",
    "updated_at": "2020-12-22T07:29:39.605Z",
    "logistic_id": 1
}
```
* **Error Response:**
    * **Content:**
         ```json 
          { "message": "Validation failed: ***", "status_code": 422 }
         ```
```json 
Here *** means the cause for which the validation failed
```

Get all variant's distribution price based on product.

* **URL**: `BASE_URL + /api/v1/dh_purchase_orders/1/variants`

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
 {
  "title": "T-shirt",
  "bn_title": "টি-শার্ট",
  "variants": [
    {
      "id": 1,
      "sku": 63,
      "product_id": 1,
      "price_distribution": "12200.0",
      "sku_code": "6334",
      "bn_sku_code": "23",
      "product_size": "23"
    }
  ]
}
```
* **Error Response:**
    * **Content:**
         ```json 
          { "message": "Couldn't find Product ***", "status_code": 422 }
         ```
```json 
Here *** means the cause for which the validation failed
```

Get all Dh_Purchase_Orders

* **URL**: `BASE_URL + /api/v1/dh_purchase_orders`

* **Method:** `GET`

* **URL Params:** 
```json
    "start_date_time": "2020-08-01",
    "end_date_time": "2022-08-01",
    "sto_no": 600,  // Integer // optional
```

* **Success Response:**
 ```json
 [
  {
    "id": 1,
    "supplier_id": 1,
    "warehouse_id": 1,
    "order_by": 1,
    "quantity": "120.0",
    "bn_quantity": "120.0",
    "total_price": "120000.0",
    "bn_total_price": "120000.0",
    "status": "Available",
    "bn_status": "Available",
    "order_date": null,
    "is_deleted": false,
    "created_at": "2020-12-22T07:19:14.731Z",
    "updated_at": "2020-12-22T07:19:14.731Z",
    "logistic_id": 1
  },
  {
    "id": 2,
    "supplier_id": 1,
    "warehouse_id": 1,
    "order_by": 1,
    "quantity": "120.0",
    "bn_quantity": "120.0",
    "total_price": "120000.0",
    "bn_total_price": "120000.0",
    "status": "Available",
    "bn_status": "Available",
    "order_date": null,
    "is_deleted": false,
    "created_at": "2020-12-22T07:29:39.605Z",
    "updated_at": "2020-12-22T07:29:39.605Z",
    "logistic_id": 1
  }
]
```

Update a Dh_Purchase_Order

* **URL**: `BASE_URL + /api/v1/dh_purchase_orders/:id`

* **Method:** `PUT`

*  **URL Params:** 
   `
   {
   "supplier_id": 1,
   "logistic_id": 1,
   "order_by": 1,
   "quantity": "120",
   "bn_quantity": "120",
   "total_price": "120000",
   "bn_total_price": "120000",
   "status": "Available",
   "bn_status": "Available"    
   }
   `

* **Success Response:**
 ```json
 {
  "id": 2,
  "supplier_id": 1,
  "logistic_id": 1,
  "order_by": 1,
  "quantity": "120.0",
  "bn_quantity": "120.0",
  "total_price": "120000.0",
  "bn_total_price": "120000.0",
  "status": "Available",
  "bn_status": "Available",
  "warehouse_id": 1,
  "order_date": null,
  "is_deleted": false,
  "created_at": "2020-12-22T07:19:14.731Z",
  "updated_at": "2020-12-22T07:19:14.731Z"
}
```
* **Error Response:**
    * **Content:**
         ```json 
          { "message": "Validation failed: ***", "status_code": 422 }
         ```
```json 
Here *** means the cause for which the validation failed
```

Delete a Dh_Purchase_Order

* **URL**: `BASE_URL + /api/v1/dh_purchase_orders/:id`

* **Method:** `DELETE`

*  **URL Params:** `None`

* **Success Response:**
 ```json 
 Successfully deleted.
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "Unable to delete DH_Purchase_Order.", "status_code": 422 }
         ```
      