### List all bundle products
___

* **URL :** `BASE_URL + /api/v1/bundles/products`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id": 3998,
    "title": "Bundle Stock Change 1",
    "slug": "bundle-stock-change-1",
    "company": "Test",
    "max_quantity_per_order": null,
    "brand": "New Testing",
    "hero_image": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/variants/8cb3mi3ocpypqnvaijsr150d5y4h/6f533330cf97d24f55e83f7a93df237b7370f26366506f8cf9eaf883bcb8c74b?response-content-disposition=inline%3B%20filename%3D%22Bug-Attendance.png%22%3B%20filename%2A%3DUTF-8%27%27Bug-Attendance.png&response-content-type=image%2Fpng&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20221222T123504Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=ddabb03a5e6bfbb2bb9a2826eef7262a26a5bec3d2952eabb4e178e9ac8b21d4",
    "supplier_tag": false
  },
  {
    "id": 3916,
    "title": "Sumon-Bundle-1",
    "slug": "sumon-bundle-1",
    "company": "Sumon",
    "max_quantity_per_order": null,
    "brand": null,
    "hero_image": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/variants/ok9ymfcwy5uxiwy48rgz1fq6w0ax/6f533330cf97d24f55e83f7a93df237b7370f26366506f8cf9eaf883bcb8c74b?response-content-disposition=inline%3B%20filename%3D%22Brand%201.jpg%22%3B%20filename%2A%3DUTF-8%27%27Brand%25201.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20221222T123505Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=a885283e13188a6d7b7b4c6de7aa6d64c18d524cf7c3e45f222b004f3100fb5a",
    "supplier_tag": false
  }
]
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch bank_account list",
   "data": {}
}
```
### List of all packed bundle variants
___

* **URL :** `BASE_URL + /api/v1/bundles/packed_variants`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully fetched packed variants.",
  "data":[
    {
      "id":3094,
      "sku":"sumon222",
      "product_id":3946,
      "product_title":"Sumon Bundle 2",
      "bundle_variants_count":2,
      "bundle_locations":[
        {
          "id":1,
          "code":"Hello",
          "quantity":0
        },
        {
          "id":72,
          "code":"09899",
          "quantity":0
        },
        {
          "id":71,
          "code":"0984",
          "quantity":96
        }
      ],
      "available_quantity":96
    },
    {
      "id":3090,
      "sku":"bundle test",
      "product_id":3942,
      "product_title":"bundle test 1",
      "bundle_variants_count":2,
      "bundle_locations":[
        {
          "id":1,
          "code":"Hello",
          "quantity":1
        }
      ],
      "available_quantity":1
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
   "message": "Unable to fetch packed variants.",
   "data": {}
}
```
### Search bundle variants.
___

* **URL :** `BASE_URL + /api/v1/bundles/search`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "search_string": "hero"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched variants.",
  "data": {
    "item_count": 4,
    "variants": [
      {
        "id": 3118,
        "sku": "hero6dsku",
        "code_by_supplier": "",
        "product_id": 3964,
        "product_title": "Hero Honda bundle",
        "price_distribution": "5000001.0",
        "product_attribute_values": [],
        "suppliers_variants": [],
        "bundle_locations": [],
        "bundle_variants": [
          {
            "variant_id": 3080,
            "sku": "heroym",
            "product_title": "Hero Honda Variable Product",
            "quantity": 10,
            "warehouse_available_quantity": 17298,
            "locations": [
              {
                "id": 62,
                "code": "Prado",
                "quantity": 279
              },
              {
                "id": 64,
                "code": "Hero Honda Location",
                "quantity": 17009
              }
            ]
          },
          {
            "variant_id": 3081,
            "sku": "herorm",
            "product_title": "Hero Honda Variable Product",
            "quantity": 10,
            "warehouse_available_quantity": 8636,
            "locations": [
              {
                "id": 62,
                "code": "Prado",
                "quantity": 0
              }
            ]
          }
        ]
      }
    ]
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
   "message": "Unable to fetch variants.",
   "data": {}
}
```
### Bundle variant details.
___

* **URL :** `BASE_URL + /api/v1/bundles/variants/:id`
* **Method :** `GET`
* **Header :** `Auth Token`
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
  "message": "Successfully fetched bundle details.",
  "data": {
    "id": 3118,
    "sku": "hero6dsku",
    "code_by_supplier": "",
    "product_id": 3964,
    "product_title": "Hero Honda bundle",
    "price_distribution": "5000001.0",
    "product_attribute_values": [],
    "suppliers_variants": [],
    "bundle_locations": [],
    "bundle_variants": [
      {
        "variant_id": 3080,
        "sku": "heroym",
        "product_title": "Hero Honda Variable Product",
        "quantity": 10,
        "warehouse_available_quantity": 17298,
        "locations": [
          {
            "id": 62,
            "code": "Prado",
            "quantity": 279
          },
          {
            "id": 1,
            "code": "Hello",
            "quantity": 7
          },
          {
            "id": 36,
            "code": "hello",
            "quantity": 3
          },
          {
            "id": 64,
            "code": "Hero Honda Location",
            "quantity": 17009
          }
        ]
      },
      {
        "variant_id": 3081,
        "sku": "herorm",
        "product_title": "Hero Honda Variable Product",
        "quantity": 10,
        "warehouse_available_quantity": 8636,
        "locations": [
          {
            "id": 62,
            "code": "Prado",
            "quantity": 0
          },
          {
            "id": 64,
            "code": "Hero Honda Location",
            "quantity": 8628
          },
          {
            "id": 14,
            "code": "self A (CW)",
            "quantity": 0
          },
          {
            "id": 1,
            "code": "Hello",
            "quantity": 3
          },
          {
            "id": 18,
            "code": "MONIKA TWO",
            "quantity": 5
          }
        ]
      },
      {
        "variant_id": 3082,
        "sku": "herogm",
        "product_title": "Hero Honda Variable Product",
        "quantity": 10,
        "warehouse_available_quantity": 7951,
        "locations": [
          {
            "id": 61,
            "code": "1122",
            "quantity": 12
          },
          {
            "id": 8,
            "code": "320",
            "quantity": 100
          },
          {
            "id": 64,
            "code": "Hero Honda Location",
            "quantity": 7839
          }
        ]
      },
      {
        "variant_id": 3085,
        "sku": "herogl",
        "product_title": "Hero Honda Variable Product",
        "quantity": 10,
        "warehouse_available_quantity": 7900,
        "locations": [
          {
            "id": 64,
            "code": "Hero Honda Location",
            "quantity": 7900
          }
        ]
      },
      {
        "variant_id": 3084,
        "sku": "herorl",
        "product_title": "Hero Honda Variable Product",
        "quantity": 10,
        "warehouse_available_quantity": 9499,
        "locations": [
          {
            "id": 62,
            "code": "Prado",
            "quantity": 500
          },
          {
            "id": 64,
            "code": "Hero Honda Location",
            "quantity": 8999
          }
        ]
      },
      {
        "variant_id": 3083,
        "sku": "heroyl",
        "product_title": "Hero Honda Variable Product",
        "quantity": 10,
        "warehouse_available_quantity": 8702,
        "locations": [
          {
            "id": 64,
            "code": "Hero Honda Location",
            "quantity": 8702
          }
        ]
      }
    ],
    "editable": true,
    "bundle_available_quantity": 0
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
   "message": "Unable to fetch bundle due to #{error.message}",
   "data": {}
}
```
### Pack a bundle product.
___

* **URL :** `BASE_URL + /api/v1/bundles/pack`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "bundle_variant_id": 3194,
  "bundle_location_id": 64,
  "bundle_quantity": 1,
  "bundle_variants": [
    {
      "variant_id": 2954,
      "packed_quantity": 1,
      "location_id": 8,
      "qr_code": "kitkat"
    },
    {
      "variant_id": 3016,
      "packed_quantity": 1,
      "location_id": 72,
      "qr_code": "cocacola2"
    }
  ]
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully packed bundle product.",
  "data":{}
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
   "success": false,
   "status": 403,
   "message": "Unable to pack bundle variant",
   "data": {}
}
```
### Unpack a bundle product.
___

* **URL :** `BASE_URL + /api/v1/bundles/un_pack`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "bundle_variant_id": 3194,
  "bundle_location_id": 1,
  "bundle_quantity": 5,
  "bundle_variants": [
    {
      "variant_id": 2954,
      "packed_quantity": 5,
      "location_id": 1,
      "qr_code": "kitkat"
    },
    {
      "variant_id": 3016,
      "packed_quantity": 5,
      "location_id": 1,
      "qr_code": "cocacola2"
    }
  ]
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully unpacked bundle product.",
  "data":{}
}
```
* **Error Response**
* **Code :**`406`
* **Content :**
```json
{
   "success": false,
   "status": 406,
   "message": "Need to unpack all quantity from a bundle.",
   "data": {}
}
```
* **Error Response**
* **Code :**`406`
* **Content :**
```json
{
   "success": false,
   "status": 406,
   "message": "Available quantity of sku - kitkatcocacola2 not enough in Central WareHouse FC",
   "data": {}
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
   "success": false,
   "status": 403,
   "message": "Unable to unpacked this variant",
   "data": {}
}
```
