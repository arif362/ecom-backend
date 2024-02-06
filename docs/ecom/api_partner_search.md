### Get all partners based on area_id
___

* **URL :** `BASE_URL + /shop/api/v1/partners`
* **Method :** `GET`
* **URL Params :**

```json
{
  "area_id": 2
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched selected partners.",
  "data": [
    {
      "id": 71,
      "name": "Mix",
      "phone": "01947758392",
      "schedule": "sat_sun_mon_tues_wed_thurs",
      "image": null,
      "latitude": "0.0",
      "longitude": "0.0",
      "partner_code": "KH12V1236",
      "retailer_code": "789379",
      "slug": "mix",
      "favourite_store": false,
      "address": {
        "district_id": 1,
        "district_name": "Narshingdi",
        "thana_id": 6,
        "thana_name": "kafrul 28",
        "area_id": 2,
        "area_name": "10 shoni tobga",
        "address_line": "Mix",
        "post_code": null
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
   "message": "Unable to fetch partners",
   "data": {}
}
```
### Get all partners based on area_id
___

* **URL :** `BASE_URL + /shop/api/v1/partners/filter`
* **Method :** `GET`
* **URL Params :**

```json
{
  "district_id": 2
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched selected partners.",
  "data": [
    {
      "id": 36,
      "name": "Noakhali Maijdee",
      "phone": "01729391044",
      "schedule": "sat_mon_wed",
      "image": "http://cdn.shopoth.net/asds58z95cn0crxdc96i101beekf",
      "latitude": "0.0",
      "longitude": "0.0",
      "partner_code": null,
      "retailer_code": null,
      "slug": "noakhali-maijdee",
      "favourite_store": false,
      "address": {
        "district_id": 2,
        "district_name": "Noakhali",
        "thana_id": 2,
        "thana_name": null,
        "area_id": 2,
        "area_name": "10 shoni tobga",
        "address_line": "n/a",
        "post_code": null
      },
      "reviews": {
        "rating_count": 0,
        "rating_avg": "0",
        "comments_count": 0
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
   "message": "Unable to process request due to ",
   "data": {}
}
```
