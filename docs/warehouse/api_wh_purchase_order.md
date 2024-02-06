**WhPurchaseOrder API's**
----
Create a Wh_Purchase_Order

* **URL:** `BASE_URL + /api/v1/wh_purchase_orders`

* **Method:** `POST`

*  **URL Params:**
   `{
   "supplier_id": 1,
   "logistic_id": 2,
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
    "id": 2,
    "supplier_id": 1,
    "order_by": 1,
    "quantity": "120.0",
    "bn_quantity": "120.0",
    "total_price": "120000.0",
    "bn_total_price": "120000.0",
    "status": "Available",
    "bn_status": "Available",
    "is_deleted": false,
    "created_at": "2020-12-22T05:07:55.970Z",
    "updated_at": "2020-12-22T05:07:55.970Z",
    "logistic_id": 2
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

Get all Supplier's price based on Variant

* **URL**: `BASE_URL + /api/v1/wh_purchase_orders/1/supplier_variant_search`

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
      "sku_code": "6334",
      "bn_sku_code": "23",
      "product_size": "23",
      "price_retail": "23333.0",
      "supplier_variants": [
        {
          "id": 1,
          "variant_id": 1,
          "supplier_id": 1,
          "supplier_price": "120.0"
        },
        {
          "id": 2,
          "variant_id": 1,
          "supplier_id": 1,
          "supplier_price": "1000.0"
        }
      ]
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
Get all Wh_Purchase_Orders

* **URL**: `BASE_URL + /api/v1/wh_purchase_orders`

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
 [
  {
    "id": 1,
    "supplier_id": 1,
    "order_by": 1,
    "quantity": "120.0",
    "bn_quantity": "120.0",
    "total_price": "120000.0",
    "bn_total_price": "120000.0",
    "status": "Available",
    "bn_status": "Available",
    "is_deleted": false,
    "created_at": "2020-12-21T10:59:50.443Z",
    "updated_at": "2020-12-21T10:59:50.443Z",
    "logistic_id": 2
  },
  {
    "id": 2,
    "supplier_id": 1,
    "order_by": 1,
    "quantity": "120.0",
    "bn_quantity": "120.0",
    "total_price": "120000.0",
    "bn_total_price": "120000.0",
    "status": "Available",
    "bn_status": "Available",
    "is_deleted": false,
    "created_at": "2020-12-22T05:07:55.970Z",
    "updated_at": "2020-12-22T05:07:55.970Z",
    "logistic_id": 2
  }
]
```

Update a Wh_Purchase_Order

* **URL**: `BASE_URL + /api/v1/wh_purchase_orders/:id`

* **Method:** `PUT`

*  **URL Params:**
   `{
   "supplier_id": 1,
   "logistic_id": 1,
   "order_by": 1,
   "quantity": "420",
   "bn_quantity": "420",
   "total_price": "420",
   "bn_total_price": "420",
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
  "quantity": "420.0",
  "bn_quantity": "420.0",
  "total_price": "420.0",
  "bn_total_price": "420.0",
  "status": "Available",
  "bn_status": "Available",
  "is_deleted": false,
  "created_at": "2020-12-22T05:07:55.970Z",
  "updated_at": "2020-12-22T05:18:23.309Z"
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

Delete a Wh_Purchase_Order

* **URL**: `BASE_URL + /api/v1/wh_purchase_orders/:id`

* **Method:** `DELETE`

*  **URL Params:** `None`

* **Success Response:**
 ```json 
 Successfully deleted.
```

* **Error Response:**
    * **Content:**
         ```json 
          { "message": "Unable to delete Wh_Purchase_Order.", "status_code": 422 }
         ```
### Return a purchase order.
___

* **URL :** `BASE_URL + /api/v1/wh_purchase_orders/:id`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "wh_purchase_order": {
    "id": 705,
    "po": "20221211OPS000705",
    "supplier_id": 107,
    "supplier_name": "MGH Supplier",
    "quantity": "60.0",
    "total_price": "26775.3",
    "vat": "15%",
    "total_price_with_vat": "30791.595",
    "price_in_words": "thirty thousand, seven hundred and ninety-one point five nine five taka only",
    "order_date": "2022-12-11T18:42:19.831+06:00",
    "qc_status": false,
    "supplier_email": "Supplier@misfit.tech",
    "bin": null,
    "attn": null,
    "po_raised_from": "Operation Team(Sourcing)",
    "supplier_group": "Supplier",
    "company_address": "21 agami ltd",
    "payment_terms": null,
    "contact_person": {
      "name": "Raisa Fareen",
      "email": "raisa.fareen@agami.ltd"
    },
    "ship_to": {
      "holding": "MGH Supplier",
      "address": "21 agami ltd",
      "attn": "sawmik.islam@agami.ltd"
    },
    "bill_to": {
      "holding": "AGAMI Limited",
      "address_line1": "Level-8, SKS Tower",
      "address_line2": "7 VIP Road, Mohakhali",
      "address_line3": "Dhaka-1206",
      "attn": "Sarajit Baral",
      "vat_id": "003279334-0203"
    },
    "issued_by": {
      "name": "Sarajit Baral",
      "designation": "Chief Executive Officer",
      "holding": "Agami Limited",
      "email": "sarajit.baral@agami.ltd"
    },
    "order_status": "Received to cwh",
    "paid": "0.0",
    "pay_status": "Not settled",
    "master_po_id": "PO-11122022-SL005",
    "line_items": [
      {
        "id": 2377,
        "variant_id": 3252,
        "product_id": 4045,
        "product_title": "Pampers Diaper 1 1-2 Year (d8b40c98-7938-11ed-bc31-01f714852f24)",
        "received_quantity": 0,
        "qc_passed": 0,
        "quality_failed": 0,
        "quantity_failed": 0,
        "qc_status": false,
        "price": "477.39",
        "quantity": 30,
        "sku": "d8b40c98-7938-11ed-bc31-01f714852f24",
        "brand": {
          "id": 113,
          "name": "Pampers",
          "created_at": "2022-12-11T15:29:00.939+06:00",
          "updated_at": "2022-12-11T15:29:01.272+06:00",
          "bn_name": "Pampers bangla",
          "is_deleted": false,
          "is_own_brand": false,
          "slug": "pampers",
          "public_visibility": true,
          "branding_layout": "full",
          "branding_promotion_with": "image",
          "branding_video_url": null,
          "branding_title": null,
          "branding_title_bn": null,
          "branding_subtitle": null,
          "branding_subtitle_bn": null,
          "short_description": null,
          "short_description_bn": null,
          "more_info_button_text": null,
          "more_info_button_text_bn": null,
          "more_info_url": null,
          "brand_info_visible": false,
          "homepage_visibility": false,
          "redirect_url": null,
          "created_by_id": 109,
          "unique_id": "4f719006-97a7-4783-875a-33dc1e890d4e"
        },
        "product_attribute_values": [
          {
            "id": 286,
            "attribute_name": "Age",
            "attribute_value": "1-2 Year"
          }
        ],
        "code_by_supplier": "",
        "sent_quantity": 0,
        "total_price": "14321.7",
        "locations": null,
        "location": null
      },
      {
        "id": 2376,
        "variant_id": 3253,
        "product_id": 4045,
        "product_title": "Pampers Diaper 1 2-3 Year (d8b40c99-7938-11ed-bc31-01f714852f24)",
        "received_quantity": 30,
        "qc_passed": 30,
        "quality_failed": 0,
        "quantity_failed": 0,
        "qc_status": true,
        "price": "415.12",
        "quantity": 30,
        "sku": "d8b40c99-7938-11ed-bc31-01f714852f24",
        "brand": {
          "id": 113,
          "name": "Pampers",
          "created_at": "2022-12-11T15:29:00.939+06:00",
          "updated_at": "2022-12-11T15:29:01.272+06:00",
          "bn_name": "Pampers bangla",
          "is_deleted": false,
          "is_own_brand": false,
          "slug": "pampers",
          "public_visibility": true,
          "branding_layout": "full",
          "branding_promotion_with": "image",
          "branding_video_url": null,
          "branding_title": null,
          "branding_title_bn": null,
          "branding_subtitle": null,
          "branding_subtitle_bn": null,
          "short_description": null,
          "short_description_bn": null,
          "more_info_button_text": null,
          "more_info_button_text_bn": null,
          "more_info_url": null,
          "brand_info_visible": false,
          "homepage_visibility": false,
          "redirect_url": null,
          "created_by_id": 109,
          "unique_id": "4f719006-97a7-4783-875a-33dc1e890d4e"
        },
        "product_attribute_values": [
          {
            "id": 287,
            "attribute_name": "Age",
            "attribute_value": "2-3 Year"
          }
        ],
        "code_by_supplier": "",
        "sent_quantity": 0,
        "total_price": "12453.6",
        "locations": null,
        "location": {
          "id": 71,
          "code": "0984",
          "warehouse_id": 46,
          "created_at": "2022-06-06T11:58:01.213+06:00",
          "updated_at": "2022-10-26T12:40:36.280+06:00",
          "created_by_id": null
        }
      }
    ],
    "created_by": {
      "id": 31,
      "name": "central_admin undefined"
    }
  }
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Unable to fetch WhPurchaseOrder."
}
```
