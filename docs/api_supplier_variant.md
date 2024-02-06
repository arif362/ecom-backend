**SupplierVariant API's**
----
Create a SupplierVariant

First we need to create Supplier and Variant to create a SupplierVariant.
Because we need those model's id in SupplierVariant model.

* **URL**: ``BASE_URL + /api/v1/supplier_variants``

* **Method:** `POST`

*  **URL Params:**
   `{"supplier_variants":
        [   
            {
                "variant_id": 1,
                "supplier_price": 1678
            },
            {
                "variant_id": 1,
                "supplier_price": 1348
            },
            {
                "variant_id": 1,
                "supplier_price": 15678
            }
        ]
   }
   `

```json 
   To crate a supplier_variant we must give variant_id and supplier_price
   as a parameter.
```

* **Success Response:**
 ```json 
 [
    {
        "id": 1
    },
    {
        "id": 2
    },
    {
        "id": 3
    }
]
```
* **Error Response:**
    * **Content:**
         ```json 
          { "message": "Validation failed: ***", "status_code": 422 }
         ```
```json 
Here *** means the cause for which the validation failed
```

Return First Ten Product by flag Search for assigning products into supplier_variant

* **URL**: `BASE_URL + /api/v1/supplier_variants/products`

* **Method:** `GET`

*  **URL Params:** 
   `
   {
   "type":1
   "search_string": "t"
   }
   `

* **Success Response:**
 ```json
 [
  {
    "id": 1,
    "title": "T-shirt",
    "variants": [
      {
        "id": 1,
        "sku": 63,
        "weight": 43.0,
        "height": 54.0,
        "width": 23.0,
        "price_distribution": "12200.0",
        "price_retailer": "13500.0",
        "price_consumer": "13100.0"
      }
    ]
  },
  {
    "id": 2,
    "title": "T-shirt",
    "variants": [
      {
        "id": 2,
        "sku": 63,
        "weight": 43.0,
        "height": 54.0,
        "width": 23.0,
        "price_distribution": "12200.0",
        "price_retailer": "13500.0",
        "price_consumer": "13100.0"
      }
    ]
  },
  {
    "id": 3,
    "title": "T-shirt",
    "variants": [
      {
        "id": 3,
        "sku": 63,
        "weight": 43.0,
        "height": 54.0,
        "width": 23.0,
        "price_distribution": "12200.0",
        "price_retailer": "13500.0",
        "price_consumer": "13100.0"
      }
    ]
  },
  {
    "id": 4,
    "title": "T-shirt",
    "variants": [
      {
        "id": 4,
        "sku": 63,
        "weight": 43.0,
        "height": 54.0,
        "width": 23.0,
        "price_distribution": "12200.0",
        "price_retailer": "13500.0",
        "price_consumer": "13100.0"
      }
    ]
  },
  {
    "id": 5,
    "title": "T-shirt",
    "variants": [
      {
        "id": 5,
        "sku": 63,
        "weight": 43.0,
        "height": 54.0,
        "width": 23.0,
        "price_distribution": "12200.0",
        "price_retailer": "13500.0",
        "price_consumer": "13100.0"
      }
    ]
  },
  {
    "id": 6,
    "title": "T-shirt",
    "variants": [
      {
        "id": 6,
        "sku": 63,
        "weight": 43.0,
        "height": 54.0,
        "width": 23.0,
        "price_distribution": "12200.0",
        "price_retailer": "13500.0",
        "price_consumer": "13100.0"
      }
    ]
  },
  {
    "id": 7,
    "title": "T-shirt",
    "variants": [
      {
        "id": 7,
        "sku": 63,
        "weight": 43.0,
        "height": 54.0,
        "width": 23.0,
        "price_distribution": "12200.0",
        "price_retailer": "13500.0",
        "price_consumer": "13100.0"
      }
    ]
  },
  {
    "id": 8,
    "title": "T-shirt",
    "variants": [
      {
        "id": 8,
        "sku": 63,
        "weight": 43.0,
        "height": 54.0,
        "width": 23.0,
        "price_distribution": "12200.0",
        "price_retailer": "13500.0",
        "price_consumer": "13100.0"
      }
    ]
  },
  {
    "id": 9,
    "title": "T-shirt",
    "variants": [
      {
        "id": 9,
        "sku": 63,
        "weight": 43.0,
        "height": 54.0,
        "width": 23.0,
        "price_distribution": "12200.0",
        "price_retailer": "13500.0",
        "price_consumer": "13100.0"
      }
    ]
  },
  {
    "id": 10,
    "title": "T-shirt",
    "variants": [
      {
        "id": 10,
        "sku": 63,
        "weight": 43.0,
        "height": 54.0,
        "width": 23.0,
        "price_distribution": "12200.0",
        "price_retailer": "13500.0",
        "price_consumer": "13100.0"
      }
    ]
  }
]
```
* **Error Response:**
    * **Content:**
         ```json 
          { "message": "Couldn't find Variant's ***", "status_code": 422 }
         ```
```json 
Here *** means the cause for which the validation failed
```

Get all SupplierVariant

* **URL**: ``BASE_URL + /api/v1/supplier_variants``

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json 
 [
    {
        "id": 1,
        "variant_id": 1,
        "supplier_id": 1,
        "supplier_price": "120.0",
        "created_at": "2020-12-21T06:27:00.783Z",
        "updated_at": "2020-12-21T06:27:00.783Z"
    },
    {
        "id": 2,
        "variant_id": 1,
        "supplier_id": 1,
        "supplier_price": "1000.0",
        "created_at": "2020-12-21T06:27:21.800Z",
        "updated_at": "2020-12-21T06:28:07.645Z"
    }
]
```
Get a specific SupplierVariant based on supplier_id

* **URL**: ``BASE_URL + /api/v1/supplier_variants/:id``

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json 
 [
    {
        "variant_id": 1,
        "supplier_price": "123.0"
    },
    {
        "variant_id": 2,
        "supplier_price": "13000.0"
    },
    {
        "variant_id": 3,
        "supplier_price": "13000.0"
    }
]
```

Delete a SupplierVariant

* **URL**: ``BASE_URL + /api/v1/supplier_variants/:id``

* **Method:** `DELETE`

*  **URL Params:**
   `None`
* **Success Response:**
```json 
{ "message": "Successfully deleted supplier_variants with id #{params[:id]}", "status_code": 200 }
```
`Here #{params[:id]} will return the id of deleted warehouse.`

* **Error Response:**
    * **Content:**
         ```json 
          { "message": "Validation failed: ***", "status_code": 422 }
         ```
```json 
Here *** means the cause for which the validation failed
```
