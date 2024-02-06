### Create review for store
___

* **URL :** `BASE_URL + /shop/api/v1/partner/review`
* **Method :** `POST`
* **Header :** `Auth Token`
* **Query Params :**
```json
{
  "warehouse_id": 49
}
```
* **Form Data :**
```json
{
  "partner_id": 157,
  "customer_order_id": 5853,
  "title": "Review",
  "description": "Good Service",
  "rating": 4,
  "is_recommended": true
}
```
* **Success Response**
 * **Code :**`201`
 * **Content :**
```json
{
  "success":true,
  "status":201,
  "message":"Successfully created store review.",
  "data":{
    "id":112,
    "title":"Review",
    "description":"Good Service",
    "rating":4,"user_id":418,
    "user_name":"ra",
    "shopoth_line_item_id":null,
    "images":[],
    "is_recommended":true,
    "reviewable":{
      "id":157,
      "type":"Partner",
      "name":"Shopoth Partner 1"
    },
    "customer_order_id":5853,
    "created_at":"2022-12-21T14:45:00.270+06:00"
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
  "message": "Customer order's record not found.",
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
   "message": "Unable to process request due to",
   "data": {}
}
```
### Create Favourite Store
___

* **URL :** `BASE_URL + /shop/api/v1/partner/make_favorite`
* **Method :** `POST`
* **Header :** `Auth Token`
* **Query Params :**
```json
{
  "warehouse_id": 8,
  "partner_id": 157
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully favorited",
  "data":{
    "partner_id":157,
    "name":"Shopoth Partner 1",
    "phone":"0176xxxxxx",
    "schedule":"sat_sun_mon_tues_wed_thurs",
    "image":null,
    "latitude":null,
    "longitude":null,
    "slug":"shopoth-partner-1",
    "favourite_store":true,
    "address":{
      "district_id":1,
      "district_name":"Narshingdi",
      "thana_id":4,
      "thana_name":"Abhaynagar",
      "area_id":14,
      "area_name":"Bogra",
      "address_line":"RA SR 1",
      "post_code":null
    },
    "reviews":{
      "rating_count":0,
      "rating_avg":0,
      "comments_count":0
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
   "message": "Unable to process request due to",
   "data": {}
}
```
### Remove store from favourite store list
___

* **URL :** `BASE_URL + /shop/api/v1/partner/unfavorite`
* **Method :** `DELETE`
* **Header :** `Auth Token`
* **Query Params :**
```json
{
  "warehouse_id": 8,
  "partner_id": 157
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Store unfavorited",
  "data":{
    "id":454,
    "user_id":418,
    "partner_id":157
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
   "message": "Unable to process request due to",
   "data": {}
}
```
### Favourite stores list
___

* **URL :** `BASE_URL + /shop/api/v1/partner/favourite_list`
* **Method :** `GET`
* **Header :** `Auth Token`
* **Query Params :**
```json
{
  "warehouse_id": 8
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Sucessfully fetched favourite stores list",
  "data": [
    {
      "partner_id":157,
      "name":"Shopoth Partner 1",
      "phone":"0176xxxxxx",
      "schedule":"sat_sun_mon_tues_wed_thurs",
      "image":null,
      "latitude":null,
      "longitude":null,
      "slug":"shopoth-partner-1",
      "favourite_store":true,
      "address":{
        "district_id":1,
        "district_name":"Narshingdi",
        "thana_id":4,
        "thana_name":"Abhaynagar",
        "area_id":14,
        "area_name":"Bogra",
        "address_line":"Shopoth Partner 1",
        "post_code":null
      },
      "reviews":{
        "rating_count":0,
        "rating_avg":0,
        "comments_count":0
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
   "message": "Unable to process request due to",
   "data": {}
}
```
### Favourite stores list
___

* **URL :** `BASE_URL + /shop/api/v1/partner/:slug`
* **Method :** `GET`
* **Header :** `Auth Token`
* **Query Params :**
```json
{
  "warehouse_id": 8
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully fetched store details.",
  "data":{
    "id":157,
    "name":"Shopoth Partner 1",
    "outlet_name":"Shopoth Partner 1",
    "owner_name":null,
    "partner_code":"SP1",
    "phone":"0176xxxxxx",
    "address":{
      "district_name":"Narshingdi",
      "thana_name":"Abhaynagar",
      "area_name":"Bogra",
      "address_line":"Shopoth Partner 1",
      "post_code":null
    },
    "schedule":"sat_sun_mon_tues_wed_thurs",
    "image":null,
    "latitude":null,
    "longitude":null,
    "favourite_store":true,
    "customer_reviews":{
      "rating_count":0,
      "rating_avg":"",
      "comment_count":0,
      "recommended":0,
      "recommended_percent":"0",
      "specified_star_count":{
        "5":0,
        "4":0,
        "3":0,
        "2":0,
        "1":0
      }
    },
    "reviews":[],
    "work_days":[
      {
        "is_opened":true,
        "opening_time":"10:00",
        "closing_time":"18:59"
      },
      {
        "is_opened":true,
        "opening_time":"18:07",
        "closing_time":"22:07"
      },
      {
        "is_opened":true,
        "opening_time":"18:07",
        "closing_time":"22:07"
      },
      {
        "is_opened":true,
        "opening_time":"18:07",
        "closing_time":"22:07"
      },
      {
        "is_opened":true,
        "opening_time":"18:07",
        "closing_time":"22:07"
      },
      {
        "is_opened":true,
        "opening_time":"18:07",
        "closing_time":"22:07"
      },
      {
        "is_opened":true,
        "opening_time":"18:07",
        "closing_time":"22:07"
      }
    ],
    "slug":"shopoth-partner-1"
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
   "message": "Unable to fetch store details.",
   "data": {}
}
```
