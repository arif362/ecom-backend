### Get the flash sale list
___

* **URL :** `BASE_URL + /api/v1/flash_sales`
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
  "success": true,
  "status": 200,
  "message": "Successfully fetched flash sale list",
  "data": [
    {
      "id": 256,
      "title": "audit",
      "title_bn": "প্রথম শো",
      "from_date": "2022-10-26",
      "to_date": "2022-11-16",
      "is_active": false,
      "start_time": "12:04",
      "end_time": "06:04",
      "running": false,
      "promotion_category": "flash_sale",
      "promotion_variants": [
        {
          "id": 810,
          "promotion_id": 256,
          "variant_id": 2954,
          "sku": "kitkat",
          "promotional_price": "4950.0",
          "promotional_discount": "50.0"
        },
        {
          "id": 811,
          "promotion_id": 256,
          "variant_id": 3178,
          "sku": "YELLOW-L",
          "promotional_price": "500.0",
          "promotional_discount": "100.0"
        }
      ],
      "created_by": {
        "id": 109,
        "name": "himi Central Admin"
      }
    },
    {
      "id": 247,
      "title": "Flash Sale 2 audir",
      "title_bn": "ফ্লাস সেল",
      "from_date": "2022-08-21",
      "to_date": "2022-08-22",
      "is_active": true,
      "start_time": "16:00",
      "end_time": "16:03",
      "running": false,
      "promotion_category": "flash_sale",
      "promotion_variants": [
        {
          "id": 802,
          "promotion_id": 247,
          "variant_id": 1,
          "sku": "12356",
          "promotional_price": "233.0",
          "promotional_discount": "0.0"
        },
        {
          "id": 803,
          "promotion_id": 247,
          "variant_id": 2,
          "sku": "2233",
          "promotional_price": "33.0",
          "promotional_discount": "0.0"
        },
        {
          "id": 804,
          "promotion_id": 247,
          "variant_id": 3,
          "sku": "333",
          "promotional_price": "32.0",
          "promotional_discount": "0.0"
        },
        {
          "id": 805,
          "promotion_id": 247,
          "variant_id": 4,
          "sku": "23",
          "promotional_price": "3.0",
          "promotional_discount": "0.0"
        },
        {
          "id": 806,
          "promotion_id": 247,
          "variant_id": 5,
          "sku": "223",
          "promotional_price": "3.0",
          "promotional_discount": "0.0"
        },
        {
          "id": 807,
          "promotion_id": 247,
          "variant_id": 6,
          "sku": "33",
          "promotional_price": "44.0",
          "promotional_discount": "0.0"
        }
      ],
      "created_by": {
        "id": null,
        "name": null
      }
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
  "message": "Unable to fetch flash sale list due to #{error.message}",
  "data": {}
}
```
### Flash sale details
___

* **URL :** `BASE_URL + /api/v1/flash_sales/:id`
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
  "success": true,
  "status": 200,
  "message": "Successfully fetched flash sale details",
  "data": {
    "id": 256,
    "title": "audit",
    "title_bn": "প্রথম শো",
    "from_date": "2022-10-26",
    "to_date": "2022-11-16",
    "is_active": false,
    "start_time": "12:04",
    "end_time": "06:04",
    "running": false,
    "promotion_category": "flash_sale",
    "promotion_variants": [
      {
        "id": 810,
        "promotion_id": 256,
        "variant_id": 2954,
        "sku": "kitkat",
        "promotional_price": "4950.0",
        "promotional_discount": "50.0"
      },
      {
        "id": 811,
        "promotion_id": 256,
        "variant_id": 3178,
        "sku": "YELLOW-L",
        "promotional_price": "500.0",
        "promotional_discount": "100.0"
      }
    ],
    "created_by": {
      "id": 109,
      "name": "himi Central Admin"
    }
  }
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": false,
  "status": 404,
  "message": "Unable to Find flash sale",
  "data": {}
}
```
### Flash sale details
___

* **URL :** `BASE_URL + /api/v1/flash_sales/:id/export_variants`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "variant_id": 2954,
    "consumer_discount": "50.0"
  },
  {
    "variant_id": 3178,
    "consumer_discount": "100.0"
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": false,
  "status": 404,
  "message": "Unable to export flash sale variants",
  "data": {}
}
```
### Flash sale create
___

* **URL :** `BASE_URL + /api/v1/flash_sales/`
* **Method :** `POST`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "flash_sale": {
    "title": "Shopoth Flash Sale",
    "title_bn": "শপথ ফ্ল্যাশ সেল",
    "from_date": "2022-12-27",
    "to_date": "2022-12-31",
    "file": "csv file"
  }
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully created flash sale",
  "data": {
    "id": 257,
    "title": "Shopoth Flash Sale",
    "title_bn": "পশপথ ফ্ল্যাশ সেল",
    "from_date": "2022-12-27",
    "to_date": "2022-12-31",
    "is_active": true,
    "start_time": "12:04",
    "end_time": "06:04",
    "running": false,
    "promotion_category": "flash_sale",
    "promotion_variants": [
      {
        "id": 810,
        "promotion_id": 256,
        "variant_id": 2954,
        "sku": "kitkat",
        "promotional_price": "4950.0",
        "promotional_discount": "50.0"
      }
    ],
    "created_by": {
      "id": 109,
      "name": "himi Central Admin"
    }
  }
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to create flash sale. Variants not found",
  "status_code": 422
}
```
### Flash sale update
___

* **URL :** `BASE_URL + /api/v1/flash_sales/:id`
* **Method :** `PUT`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "flash_sale": {
    "title": "Shopoth Flash Sale Update",
    "title_bn": "শপথ ফ্ল্যাশ সেল",
    "from_date": "2022-12-27",
    "to_date": "2022-12-31",
    "file": "csv file"
  }
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully updated flash sale",
  "data": {
    "id": 257,
    "title": "Shopoth Flash Sale Update",
    "title_bn": "পশপথ ফ্ল্যাশ সেল",
    "from_date": "2022-12-27",
    "to_date": "2022-12-31",
    "is_active": true,
    "start_time": "12:04",
    "end_time": "06:04",
    "running": false,
    "promotion_category": "flash_sale",
    "promotion_variants": [
      {
        "id": 810,
        "promotion_id": 256,
        "variant_id": 2954,
        "sku": "kitkat",
        "promotional_price": "4950.0",
        "promotional_discount": "50.0"
      }
    ],
    "created_by": {
      "id": 109,
      "name": "himi Central Admin"
    }
  }
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to update flash sale. error: #{error}",
  "status_code": 422
}
```
### Flash sale delete
___

* **URL :** `BASE_URL + /api/v1/flash_sales/:id`
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
  "message": "Flash sale is successfully made inactive with id #{params[:id]",
  "status_code": 200
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to delete/make inactive Flash sale. error: #{error}",
  "status_code": 422
}
```
