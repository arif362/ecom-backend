**Locations API's**
----
Get all locations

* **URL:** `BASE_URL + /api/v1/locations`

* **Method:** `GET`

* **Authorization:** `staff_auth`

* **URL Params:**

* **Success Response:**
 ```json
 [
  {
    "id": 1,
    "code": "JR-01-A-A-101",
    "warehouse_id": 5,
    "warehouse": {
      "id": 5,
      "name": "Narsingdi FC",
      "address": {
        "id": 953,
        "district_id": 2
      }
    }
  },
  {
    "id": 2,
    "code": "JR-01-A-A-102",
    "warehouse_id": 5,
    "warehouse": {
      "id": 5,
      "name": "Narsingdi FC",
      "address": {
        "id": 953,
        "district_id": 2
      }
    }
  },
  {
    "id": 9,
    "code": "JR-01-A-A-201",
    "warehouse_id": 5,
    "warehouse": {
      "id": 5,
      "name": "Narsingdi FC",
      "address": {
        "id": 953,
        "district_id": 2
      }
    }
  }
]
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```

Get locations for a specific variant

* **URL:** `BASE_URL + /api/v1/locations/variants/2`

* **Method:** `GET`

* **Authorization:** `staff_auth`

* **URL Params:**

* **Success Response:**
 ```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched location list.",
  "data": [
    {
      "id": 40,
      "code": "JR-01-A-F-202",
      "quantity": 1
    }
  ]
}
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
    * **If variant not found then:**
 ```json
 {
  "success": false,
  "status": 404,
  "message": "Variant not found.",
  "data": {}
}
```
  * **If other error occurred, then:**
 ```json
 {
  "success": false,
  "status": 404,
  "message": "Unable to Show Location list.",
  "data": {}
}
```
### Location Details
___

* **URL :** `BASE_URL + /api/v1/locations/:id`
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
  "id": 57,
  "code": "Bogura-L-1",
  "created_by": {
    "id": null,
    "name": null
  },
  "variants": [
    {
      "product_id": 3864,
      "product_title": "Pirapat coca cola",
      "variant_id": 2958,
      "sku": "pirapat-1",
      "quantity": 380
    },
    {
      "product_id": 3841,
      "product_title": "Pran wafer don t touch this product without rakib",
      "variant_id": 2924,
      "sku": "p12",
      "quantity": 2
    },
    {
      "product_id": 3863,
      "product_title": "Habijabi",
      "variant_id": 2957,
      "sku": "habijabi",
      "quantity": 4
    },
    {
      "product_id": 3934,
      "product_title": "Dairy Milk silk",
      "variant_id": 3076,
      "sku": "milk",
      "quantity": 100
    },
    {
      "product_id": 3982,
      "product_title": "Tissue",
      "variant_id": 3145,
      "sku": "tissue",
      "quantity": 2
    },
    {
      "product_id": 4002,
      "product_title": "Sun Chips update",
      "variant_id": 3177,
      "sku": "GARLICANDCHILLI-100G",
      "quantity": 70
    },
    {
      "product_id": 3903,
      "product_title": "Cocacola",
      "variant_id": 3017,
      "sku": "cocacola3",
      "quantity": 10
    },
    {
      "product_id": 4007,
      "product_title": "new variable product",
      "variant_id": 3197,
      "sku": "var 2",
      "quantity": 15
    },
    {
      "product_id": 4002,
      "product_title": "Sun Chips update",
      "variant_id": 3176,
      "sku": "SALTANDPAPER-60G",
      "quantity": 100
    },
    {
      "product_id": 4007,
      "product_title": "new variable product",
      "variant_id": 3198,
      "sku": "var 3",
      "quantity": 5
    },
    {
      "product_id": 4003,
      "product_title": "Mens Full Sleeves Plain Shirt 200",
      "variant_id": 3179,
      "sku": "YELLOW-M",
      "quantity": 7
    },
    {
      "product_id": 3860,
      "product_title": "Kitkat",
      "variant_id": 2954,
      "sku": "kitkat",
      "quantity": 31
    }
  ]
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to find location type due to #{ex.message}"
}
```
### Location Transfer
___

* **URL :** `BASE_URL + /api/v1/locations/transfer`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "present_location_id": 57,
  "transfer_location_id": 64,
  "variant_id": 3145,
  "quantity": "1"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": "Successfully transferred quantity.",
  "status_code": 200
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Warehouse variant not found.",
  "status_code": 404
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
  "message": "Can't transferred because current location's quantity is less than transfer quantity",
  "status_code": 403
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Failed due to #{error.message}",
  "status_code": 422
}
```
### Location Create
___

* **URL :** `BASE_URL + /api/v1/locations`
* **Method :** `POST`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "location": {
    "code": "Dhaka-L1"
  }
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "id": 105,
  "code": "Dhaka-L1",
  "warehouse_id": 8,
  "created_by_id": 7,
  "warehouse": {
    "id": 8,
    "name": "Narshingdi",
    "address": {
      "id": 2374,
      "district_id": 2
    }
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
  "message": "Unable to create Location due to: #{error.message}",
  "data": {}
}
```
### Location Update
___

* **URL :** `BASE_URL + /api/v1/locations/:id`
* **Method :** `PUT`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "location": {
    "code": "Narsingdhi-L1"
  }
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "warehouse_id": 8,
  "id": 105,
  "code": "Narsingdhi-L1",
  "created_by_id": 7,
  "warehouse": {
    "id": 8,
    "name": "Narshingdi",
    "address": {
      "id": 2374,
      "district_id": 2
    }
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
  "message": "Unable to update Location due to: #{error.message}",
  "data": {}
}
```
### Location Delete
___

* **URL :** `BASE_URL + /api/v1/locations/:id`
* **Method :** `DELETE`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "status_code": 200,
  "message": "Delete Success!"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to find location type due to #{ex.message}"
}
```
