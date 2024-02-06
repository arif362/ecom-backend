### Blocked Items list
___

* **URL :** `BASE_URL + /api/v1/blocked_items`
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
    "id":133,
    "product_title":"Nokia 11001",
    "sku":"642642",
    "blocked_quantity":2,
    "garbage_quantity":0,
    "unblocked_quantity":0,
    "blocked_reason":"Product is expired",
    "variant_id":36
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
### Create Blocked Items
___

* **URL :** `BASE_URL + /api/v1/blocked_items`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "variant_id": 2954,
  "blocked_quantity": 5,
  "blocked_reason": "Product is damaged",
  "location_id": 53,
  "note": "None"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{ 
  "message": "Successfully blocked #{quantity} quantity.", 
  "status_code": 200
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
   "success": false,
   "status": 403,
   "message": "Unable to block this variant",
   "data": {}
}
```
### Blocked Item Details
___

* **URL :** `BASE_URL + /api/v1/blocked_items/:id`
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
  "id":133,
  "blocked_quantity":2,
  "garbage_quantity":0,
  "unblocked_quantity":0,
  "remaining_blocked_quantity":2,
  "locations":[
    {
      "id":7,
      "code":"310",
      "warehouse_id":46,
      "created_at":"2021-01-26T18:19:58.422+06:00",
      "updated_at":"2021-01-26T18:19:58.422+06:00",
      "created_by_id":null
    },
    {
      "id":8,
      "code":"320",
      "warehouse_id":46,
      "created_at":"2021-01-26T18:20:06.816+06:00",
      "updated_at":"2021-01-26T18:20:06.816+06:00",
      "created_by_id":null
    }
  ]
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
   "success": false,
   "status": 403,
   "message": "Unable to block this variant",
   "data": {}
}
```
### Unblock variant quantity
___

* **URL :** `BASE_URL + /api/v1/blocked_items/unblock/:id`
* **Method :** `PUT`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message":"Successfully unblocked 1 quantity.",
  "status_code":200
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
   "success": false,
   "status": 403,
   "message": "Unable to unblock this variant.",
   "data": {}
}
```
### Unblock variant quantity
___

* **URL :** `BASE_URL + /api/v1/blocked_items/garbage/:id`
* **Method :** `PUT`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message":"#{quantity} quantity moved into garbage.",
  "status_code":200
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
   "success": false,
   "status": 403,
   "message": "Unable to move this quantity into garbage.",
   "data": {}
}
```
### Export Blocked Items
___

* **URL :** `BASE_URL + /api/v1/blocked_items/export`
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
    "id":133,
    "product_title":"Nokia 11001",
    "sku":"642642",
    "blocked_quantity":2,
    "garbage_quantity":0,
    "unblocked_quantity":1,
    "blocked_reason":"Product is expired",
    "variant_id":36,
    "product_code":31,
    "category":"Phones/ Mobiles and Accessories",
    "sub_category":"Phones/ Mobiles and Accessories",
    "quantity":2,
    "mrp":"1.0"
  }
]
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
   "success": false,
   "status": 403,
   "message": "Unable to find blocked items due to #{ex.message}",
   "data": {}
}
```
### Blocked Items list
___

* **URL :** `BASE_URL + /api/v1/blocked_items/blocked_reasons`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "start_date_time": "2022-11-23",
  "end_date_time": "2022-12-22"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "key":"product_is_expired",
    "value":"Product is expired"
  },
  {
    "key":"product_is_damaged",
    "value":"Product is damaged"
  },
  {
    "key":"package_is_damaged",
    "value":"Package is damaged"
  },
  {
    "key":"seal_broken",
    "value":"Seal broken"
  },
  {
    "key":"damaged_at_warehouse",
    "value":"Damaged at warehouse"
  }
]
```

