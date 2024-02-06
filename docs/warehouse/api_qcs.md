**QCS API**

***Fetch QCS LineItem***

* **URL:** `BASE_URL + /api/v1/qcs/line_item

* **Method:** `GET`

* **URL Params:**
* params do
    * requires :order_id, type: Integer
    * requires :line_item_id, type: Integer
    * optional :order_type, type: String *//Example: 'ReturnTransferOrder'*
* end

* **Success Response:**
 ```json
{
  "id": 1767,
  "order_id": 1,
  "order_type": "ReturnTransferOrder",
  "received_quantity": 1,
  "qc_passed": 1,
  "quality_failed": 0,
  "quantity_failed": 0,
  "qc_status": true,
  "variant_id": 3121,
  "product_title": "Nutella Hazelnut Cocoa Spread test2-sweet (Nutella2)",
  "sku": "Nutella2",
  "category_id": 282,
  "price": "485.0",
  "total_price": "485.0",
  "due_quantity": 1,
  "location": null,
  "product_id": 3966,
  "code_by_supplier": "",
  "sent_quantity": 1,
  "available_in_locations": [
    {
      "id": 14,
      "code": "self A (CW)",
      "quantity": 455
    }
  ]
}
```

***Fetch QCS LineItemByOrder***

* **URL:** `BASE_URL + /api/v1/qcs/line_item_by_order

* **Method:** `GET`

* **URL Params:**
* params do
    * requires :order_id, type: Integer
    * requires :order_type, type: String *//Example: 'ReturnTransferOrder'*
* end

* **Success Response:**
 ```json
[
  {
    "id": 1767,
    "order_id": 1,
    "order_type": "ReturnTransferOrder",
    "received_quantity": 1,
    "qc_passed": 1,
    "quality_failed": 0,
    "quantity_failed": 0,
    "qc_status": true,
    "variant_id": 3121,
    "product_title": "Nutella Hazelnut Cocoa Spread test2-sweet (Nutella2)",
    "sku": "Nutella2",
    "category_id": 282,
    "price": "485.0",
    "total_price": "485.0",
    "due_quantity": 1,
    "location": null,
    "product_id": 3966,
    "code_by_supplier": "",
    "sent_quantity": 1,
    "available_in_locations": [
      {
        "id": 14,
        "code": "self A (CW)",
        "quantity": 455
      }
    ]
  },
  {
    "id": 1768,
    "order_id": 1,
    "order_type": "ReturnTransferOrder",
    "received_quantity": 1,
    "qc_passed": 1,
    "quality_failed": 0,
    "quantity_failed": 0,
    "qc_status": true,
    "variant_id": 3120,
    "product_title": "Nutella Hazelnut Cocoa Spread test-chocolate (Nutella1)",
    "sku": "Nutella1",
    "category_id": 282,
    "price": "480.0",
    "total_price": "480.0",
    "due_quantity": 1,
    "location": null,
    "product_id": 3966,
    "code_by_supplier": "",
    "sent_quantity": 1,
    "available_in_locations": [
      {
        "id": 14,
        "code": "self A (CW)",
        "quantity": 455
      }
    ]
  }
]
```


***QCS Quality Control By Variant***

* **URL:** `BASE_URL + /api/v1/qcs/quality_control

* **Method:** `POST`

* **URL Params:**
* params do
  * requires :order, type: Hash do
    * requires :order_id, type: Integer
    * optional :order_type, type: String  *//Example: 'ReturnTransferOrder'*
    * requires :variant_id, type: Integer
    * requires :received_quantity, type: Integer
    * requires :passed_quantity, type: Integer
    * requires :failed_quantity, type: Integer
    * requires :failed_reasons, type: Array
  * end
* end

* **Success Response:**
 ```json
{
  "id": 1768,
  "order_id": 1,
  "order_type": "ReturnTransferOrder",
  "received_quantity": 1,
  "qc_passed": 1,
  "quality_failed": 0,
  "quantity_failed": 0,
  "qc_status": true,
  "variant_id": 3120,
  "product_title": "Nutella Hazelnut Cocoa Spread test-chocolate (Nutella1)",
  "sku": "Nutella1",
  "category_id": 282,
  "price": "480.0",
  "total_price": "480.0",
  "due_quantity": 1,
  "location": null,
  "product_id": 3966,
  "code_by_supplier": "",
  "sent_quantity": 1,
  "available_in_locations": null
}
```

***Get failed items***

* **URL:** `BASE_URL + /api/v1/qcs/qc_failed_items

* **Method:** `GET`

* **URL Params:**
* params do
  * requires :order_type, type: String  *//Example: 'DhPurchaseOrder' or 'WhPurchaseOrder' or 'ReturnCustomerOrder' or 'ReturnTransferOrder'*
  * optional :order_id, type: Integer
  * optional :sku, type: String
  * optional :code_by_supplier, type: String
* end

* **Success Response:**
 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched failed qcs.",
  "data": [
    {
      "order_id": 67,
      "order_type": "ReturnTransferOrder",
      "failed_qc_id": 637,
      "quantity_failed": 2,
      "variant_id": 3121,
      "sku": "Nutella2",
      "title": "Nutella Hazelnut Cocoa Spread",
      "failed_type": "quantity_failed",
      "received_quantity": 0,
      "closed_quantity": 0,
      "open_quantity": 2,
      "is_settled": false
    }
  ]
}
```

* **Error Response:**
 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch failed qcs.",
  "data": {}
}
```
### Fetch product list of a order
___

* **URL :** `BASE_URL + /api/v1/qcs/line_items_by_order`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "order_type": "WhPurchaseOrder",
  "order_id": 705
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id": 2377,
    "order_id": 705,
    "order_type": "WhPurchaseOrder",
    "received_quantity": 0,
    "qc_passed": 0,
    "quality_failed": 0,
    "quantity_failed": 0,
    "qc_status": false,
    "variant_id": 3252,
    "product_title": "Pampers Diaper 1 1-2 Year (d8b40c98-7938-11ed-bc31-01f714852f24)",
    "sku": "d8b40c98-7938-11ed-bc31-01f714852f24",
    "category_id": 465,
    "price": "477.39",
    "total_price": "14321.7",
    "due_quantity": 30,
    "location": null,
    "product_id": 4045,
    "code_by_supplier": "",
    "sent_quantity": 0,
    "available_in_locations": []
  },
  {
    "id": 2376,
    "order_id": 705,
    "order_type": "WhPurchaseOrder",
    "received_quantity": 30,
    "qc_passed": 30,
    "quality_failed": 0,
    "quantity_failed": 0,
    "qc_status": true,
    "variant_id": 3253,
    "product_title": "Pampers Diaper 1 2-3 Year (d8b40c99-7938-11ed-bc31-01f714852f24)",
    "sku": "d8b40c99-7938-11ed-bc31-01f714852f24",
    "category_id": 465,
    "price": "415.12",
    "total_price": "12453.6",
    "due_quantity": 30,
    "location": {
      "id": 71,
      "code": "0984",
      "warehouse_id": 46,
      "created_at": "2022-06-06T11:58:01.213+06:00",
      "updated_at": "2022-10-26T12:40:36.280+06:00",
      "created_by_id": null
    },
    "product_id": 4045,
    "code_by_supplier": "",
    "sent_quantity": 0,
    "available_in_locations": [
      {
        "id": 71,
        "code": "0984",
        "quantity": 30
      }
    ]
  }
]

```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "status_code": 404,
  "message": "Unable to fetch line items."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Unable to fetch line items due to: #{error.message}"
}
```
