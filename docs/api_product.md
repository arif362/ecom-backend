**Products API's**
----
Create a product

* **URL**: ``BASE_URL + /api/v1/products``

* **Method:** `POST` 

  * **URL Params:** 
  `{"product": {
     "title": "Nokia N97", 
     "bn_title": "Nokia N97",
     "is_trending": false,
     "is_daily_deals": true,
     "is_new_arrival": false,
     "is_best_selling": false,
     "description": '',
     "bn_description": '',
     "short_description": '',
     "bn_short_description": '',
     "warranty_type": '', // 1
     "warranty_period": '',
     "warranty_policy": '',
     "bn_warranty_policy": '',
     "dangerous_goods": '', // 1
     "inside_box": '',
     "bn_inside_box": '',
     "video_url": '',
     "sku_type": '', // 1
     "image": '', // file
     "warranty_policy": '',
     "company": '',
     "bn_company": '',
     "certification": '',
     "bn_certification": '',
     "license_required": '',
     "bn_license_required": '',
     "material": '',
     "bn_material": '',
     "consumption_guidelines": '',
     "bn_consumption_guidelines": '',
     "temperature_requirement": '',
     "bn_temperature_requirement": '',
     "keywords": '',
     "tagline": '',
     "hero_image_file": file,
     "images": files,
     "product_type": "0",
     "product_specifications": ,
     "is_emi_available": true,
     "tenures": [3, 6, 9],
     "bundle_variants": [
        {
            sku_id: 34 //
            quantity: 2 //float
        }
     ]
     "variants_attributes": [
          {
           "sku": "63", //string
           "weight": "56", //float
           "height": "85", //float
           "width": "45", //float
           "depth": "23", //float
           "weight_unit": "23", //string
           "height_unit": "23", //string
           "width_unit": "23", //string
           "depth_unit": "23", //string
           "primary": false,
           "price_consumer": 120,
           "sku_case_dimension": "12*12",
           "sku_case_width": "12*12", //float
           "sku_case_length": "12*12", //float
           "sku_case_height": "12*12", //float
           "sku_case_width_unit": "12*12", //string
           "sku_case_length_unit": "12*12", //string
           "sku_case_height_unit": "12*12", //string
           "case_weight_unit": "12*12", //string
           "case_weight": "12200", //string
           "consumer_discount": 10.0,
           "vat_tax": 100.0,
           "discount_type": "Discount",
           "moq": 100.0,
           "code_by_supplier": "kajs",
           "product_attribute_value_ids": [1, 2, 3],
           "is_deleted": false,
       }
     ],
     "frequently_asked_questions_attributes": [
           {
            "question": "Valid quesstions?",
            "bn_question": "Valid quesstions?",
            "answer": "Valid quesstions?",
            "bn_answer": "Valid quesstions?",
           }
     ],
   "category_ids": [1, 2, 3],
   "product_type_ids": [1, 2, 3],
   "leaf_category_id": 100,
   "product_attribute_images_attributes": [
       {
        "product_attribute_value_id": 1,
        "is_default": false,
        "images_file": []
       }
     ]
 }}`

Get all products

* **URL**: ``BASE_URL + /api/v1/products/:id``

* **Method:** `GET` 
  
*  **URL Params:** `None`

* **Success Response:**
 ```json
```

  * **Code:** `200`
* **Error Response:**
  * **Code:** `422`
  * **Content:** 
       ```json 
        { "message": "", "status_code":  }
       ```

***products skus search***

* **URL:** `BASE_URL + /api/v1/products/skus/search

* **Method:** `POST`

* **URL Params:**
  `{
  "search_string": "kit"
  "order_type": "sto" # "For return_transfer_order order_type will be 'rto'"
  }`

* **Success Response:**
 ```json
{
  "If order_type == 'rto'": {
    "item_count": 1,
    "variants": [
      {
        "id": 2,
        "sku": "H-26-P385-FRD-000868",
        "code_by_supplier": "",
        "product_id": 2,
        "product_title": "Freedom Pregnancy Test Cassette",
        "price_distribution": "65.0",
        "product_attribute_values": [],
        "locations": [
          {
            "id": 40,
            "code": "JR-01-A-F-202",
            "quantity": 1
          }
        ]
      }
    ]
  },
  "else": {
    "item_count": 1,
    "variants": [
      {
        "id": 2954,
        "sku": "kitkat",
        "code_by_supplier": "",
        "product_id": 3860,
        "product_title": "Kitkat",
        "price_distribution": "2000.0",
        "product_attribute_values": [],
        "suppliers_variants": [
          {
            "id": 320,
            "variant_id": 2954,
            "supplier_id": 79,
            "supplier_name": "Unilever",
            "supplier_price": "100.0"
          },
          {
            "id": 326,
            "variant_id": 2954,
            "supplier_id": 81,
            "supplier_name": "Rakib supplier",
            "supplier_price": "100.0"
          }
        ]
      }
    ]
  }
}
```
### Product Change Log
___

* **URL :** `BASE_URL + /api/v1/products/:id/changes_log`

* **Method :** `GET`

* **URL Params :**

```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched product changes log",
  "data": [
    {
      "id": 20328,
      "action": "create",
      "auditable_id": 4037,
      "auditable_type": "Product",
      "created_by": {
        "id": 106,
        "first_name": "central",
        "last_name": "admin",
        "email": "shopoth@central.com",
        "staff_role_id": 1,
        "warehouse_id": 46,
        "created_at": "2022-09-13T13:09:17.366+06:00",
        "updated_at": "2022-09-13T13:09:17.366+06:00",
        "address_line": null,
        "unit": "central_warehouse",
        "is_active": true,
        "staffable_id": 46,
        "staffable_type": "Warehouse"
      },
      "created_at": "2022-10-24T16:45:48.132+06:00",
      "audited_changes": {
        "title": "test-var-up3",
        "description": null,
        "bn_title": null,
        "bn_description": null,
        "is_deleted": false,
        "short_description": null,
        "bn_short_description": null,
        "warranty_period": null,
        "warranty_policy": null,
        "bn_warranty_policy": null,
        "inside_box": null,
        "bn_inside_box": null,
        "video_url": null,
        "warranty_type": 0,
        "dangerous_goods": null,
        "sku_type": 1,
        "warranty_period_type": null,
        "company": "ABC Company",
        "bn_company": "",
        "certification": null,
        "bn_certification": null,
        "license_required": null,
        "material": null,
        "bn_material": null,
        "bn_broad_description": null,
        "consumption_guidelines": null,
        "bn_consumption_guidelines": null,
        "temperature_requirement": "",
        "bn_temperature_requirement": "",
        "keywords": null,
        "tagline": null,
        "product_type": "Featured",
        "product_specifications": null,
        "status": "new",
        "leaf_category_id": 403,
        "brand_id": 18,
        "root_category_id": 347,
        "brand_message": null,
        "slug": "test-var-up3",
        "sell_count": 0,
        "is_refundable": true,
        "return_policy": "",
        "bn_return_policy": "",
        "attribute_set_id": 8,
        "image_attribute_id": 38,
        "public_visibility": true,
        "expiry_duration": "",
        "expiry_limit": 0,
        "max_quantity_per_order": null,
        "weight": 0,
        "is_emi_available": false,
        "tenures": [],
        "created_by_id": 106
      }
    },
    {
      "id": 20333,
      "action": "update",
      "auditable_id": 4037,
      "auditable_type": "Product",
      "created_by": {
        "id": 106,
        "first_name": "central_admin",
        "last_name": "Shopoth",
        "email": "shopoth@central.com",
        "staff_role_id": 1,
        "warehouse_id": 46,
        "created_at": "2022-09-13T13:09:17.366+06:00",
        "updated_at": "2022-09-13T13:09:17.366+06:00",
        "address_line": null,
        "unit": "central_warehouse",
        "is_active": true,
        "staffable_id": 46,
        "staffable_type": "Warehouse"
      },
      "created_at": "2022-10-24T16:50:07.377+06:00",
      "audited_changes": {
        "bn_title": [
          null,
          ""
        ],
        "description": [
          null,
          ""
        ],
        "bn_description": [
          null,
          ""
        ],
        "short_description": [
          null,
          ""
        ],
        "bn_short_description": [
          null,
          ""
        ],
        "warranty_period": [
          null,
          ""
        ],
        "warranty_policy": [
          null,
          ""
        ],
        "bn_warranty_policy": [
          null,
          ""
        ],
        "inside_box": [
          null,
          ""
        ],
        "bn_inside_box": [
          null,
          ""
        ],
        "video_url": [
          null,
          ""
        ],
        "dangerous_goods": [
          null,
          ""
        ],
        "certification": [
          null,
          ""
        ],
        "bn_certification": [
          null,
          ""
        ],
        "license_required": [
          null,
          ""
        ],
        "material": [
          null,
          ""
        ],
        "bn_material": [
          null,
          ""
        ],
        "bn_broad_description": [
          null,
          ""
        ],
        "consumption_guidelines": [
          null,
          ""
        ],
        "bn_consumption_guidelines": [
          null,
          ""
        ],
        "keywords": [
          null,
          ""
        ],
        "tagline": [
          null,
          ""
        ]
      }
    }
  ]
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
   "success": false,
   "status": 404,
   "message": "Unable to find product",
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
   "message": "Unable to fetch product changes log",
   "data": {}
}
```
### Product Category Change Log
___

* **URL :** `BASE_URL + /api/v1/products/:id/categories_log`

* **Method :** `GET`

* **URL Params :**

```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched product category changes log",
  "data": [
    {
      "id": 20332,
      "action": "create",
      "auditable_id": 8292,
      "auditable_type": "ProductCategory",
      "created_by": {
        "id": 106,
        "first_name": "central",
        "last_name": "admin",
        "email": "shopoth@central.com",
        "staff_role_id": 1,
        "warehouse_id": 46,
        "created_at": "2022-09-13T13:09:17.366+06:00",
        "updated_at": "2022-09-13T13:09:17.366+06:00",
        "address_line": null,
        "unit": "central_warehouse",
        "is_active": true,
        "staffable_id": 46,
        "staffable_type": "Warehouse"
      },
      "created_at": "2022-10-24T16:45:48.187+06:00",
      "audited_changes": {
        "product_id": 4037,
        "category_id": 403,
        "sub_category_id": null,
        "created_by_id": null
      }
    }
  ]
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
   "success": false,
   "status": 404,
   "message": "Unable to find product",
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
   "message": "Unable to fetch product changes log",
   "data": {}
}
```