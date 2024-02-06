### Return all partners
___
* **URL :** `BASE_URL + customer_care/api/v1/partners`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "district_id": 1,
  "thana_id": 3,
  "area_id": 22
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "partner_id":178,
    "name":"Honda Seller Storeeee",
    "address":"r54rerere",
    "district":"Narshingdi",
    "thana":"Kahalu",
    "area":"th-3 area-1"
  },
  {
    "partner_id":176,
    "name":"afzal store",
    "address":"33",
    "district":"Narshingdi",
    "thana":"Kahalu",
    "area":"th-3 area-1"
  },
  {
    "partner_id":151,
    "name":"Honda Seller Storeeee",
    "address":"Kahalu, Narshingdi.",
    "district":"Narshingdi",
    "thana":"Kahalu",
    "area":"th-3 area-1"
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": false,
  "message": "Partners not found"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "#{error}"
}
```
### Return partners by area_id filtering
___
* **URL :** `BASE_URL + customer_care/api/v1/partners/areas/:id`
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
    "partner_id":178,
    "name":"Honda Seller Storeeee",
    "address":"r54rerere",
    "district":"Narshingdi",
    "thana":"Kahalu",
    "area":"th-3 area-1"
  },
  {
    "partner_id":176,
    "name":"afzal store",
    "address":"33",
    "district":"Narshingdi",
    "thana":"Kahalu",
    "area":"th-3 area-1"
  },
  {
    "partner_id":151,
    "name":"Honda Seller Storeeee",
    "address":"Kahalu, Narshingdi.",
    "district":"Narshingdi",
    "thana":"Kahalu",
    "area":"th-3 area-1"
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": false,
  "message": "Partners not found"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "#{error}"
}
```
### Get partner details
___
* **URL :** `BASE_URL + customer_care/api/v1/partners/:id`
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
  "id":178,
  "warehouse_name":"Narshingdi",
  "warehouse_bangle_name":"Narshingdissdddd",
  "created_at":"2022-12-13T18:21:08.011+06:00",
  "warehouse_email":"sajjad@misfit.tech",
  "warehouse_phone":"01670174363",
  "schedule":"Sat sun mon tues wed thurs",
  "address":
  {
    "address_line":"r54rerere",
    "area":"th-3 area-1",
    "thana":"Kahalu",
    "district":"Narshingdi",
    "post_code":null
  }
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": false,
  "message": "Partners not found"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to return details due to #{error.message}"
}
```
