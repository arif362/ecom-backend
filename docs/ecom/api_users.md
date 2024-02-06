### Get logged in user information.
___

* **URL :** `BASE_URL + /shop/api/v1/users/current`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

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
  "message":"Successfully fetched user information.",
  "data":{
    "full_name":"shopoth user",
    "email":"",
    "phone":"0185xxxxxxx",
    "gender":"xxx",
    "date_of_birth":"2022-08-29",
    "registered_at":"2022-09-01T10:51:59.066+06:00",
    "images":{"app_img":"","web_img":""},
    "addresses":[
      {"id":3057,
        "address_title":"others",
        "name":"ra","bn_name":null,
        "phone":"0185xxxxxxx","district_id":1,
        "thana_id":13,
        "area_id":4,
        "district_name":"Narshingdi",
        "district_bn_name":"Narshingdi",
        "thana_name":"Bogra",
        "thana_bn_name":"BN Bogra",
        "area_name":"Noapara",
        "area_bn_name":"নওয়াপাড়া",
        "address_line":"avc",
        "bn_address_line":null,
        "zip_code":null
      }],
    "favorite_stores":[
      {
        "partner_id":157,
        "name":"Shopoth Partner",
        "phone":"0176xxxxxxx",
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
          "address_line":"SP 1",
          "post_code":null
        },
        "reviews":{
          "rating_count":0,
          "rating_avg":0,
          "comments_count":0
        }
      }
    ],
    "cart":null,
    "whatsapp":"0185xxxxxx",
    "viber":null,
    "imo":null,
    "preferred_name":"sp"
  }}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch user information",
   "data": {}
}
```
### Create a new ecom user.
___

* **URL :** `BASE_URL + /shop/api/v1/users/signup`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "full_name": "Shopoth User 2",
  "phone": "01761212121",
  "email": "",
  "gender": 1,
  "date_of_birth": "2000-01-26",
  "password": "123456"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "User registration successful.",
  "data": {
    "full_name": "Shopoth User 2",
    "email": "",
    "phone": "01761212121",
    "images": {
      "app_img": "",
      "web_img": ""
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
   "message": "User registration failed",
   "data": {}
}
```
### Ecom user login
___

* **URL :** `BASE_URL + /shop/api/v1/users/signup`
* **Method :** `POST`
* **URL Params :**

```json
{
  "email_or_phone": "0185xxxxxxx",
  "password": "123456"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully logged in.",
  "data": {
    "token": "bearer-token",
    "name": "shopoth user",
    "phone": "0185xxxxxxx",
    "cart": null,
    "is_ambassador": true,
    "ambassador_name": "suser"
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
   "message": "Login failed",
   "data": {}
}
```
### Ecom user logout
___

* **URL :** `BASE_URL + /shop/api/v1/users/sign_out`
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
  "success": true,
  "status": 200,
  "message": "Successfully logout"
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Ecommerce user logout failed",
   "data": {}
}
```
### Verify auth token login user.
___

* **URL :** `BASE_URL + /shop/api/v1/users/verify_auth_token`
* **Method :** `GET`
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
  "message": "token info fetched successful",
  "data":{
    "valid":true
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
   "message": "Unable to fetch token info",
   "data": {}
}
```
### Upload or update user image.
___

* **URL :** `BASE_URL + /shop/api/v1/users/image`
* **Method :** `PUT`
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
  "message":"Successfully uploaded image for user.",
  "data":{
    "full_name":"shopoth user",
    "email":"",
    "phone":"0185xxxxxxx",
    "images":{
      "app_img":"http://cdn.shopoth.net/variants/1cp9vgrf7g61plk0nq6g43afcqay/f9e93ed00f659178f5d9dd0219fa6f4534090099",
      "web_img":"http://cdn.shopoth.net/variants/1cp9vgrf7g61plk0nq6g43afcqay/033bd1b05feeb378fea3ab4eb5a34a6270"
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
   "message": "Unable to upload image for user",
   "data": {}
}
```
### Upload or update user image.
___

* **URL :** `BASE_URL + /shop/api/v1/users/image`
* **Method :** `PUT`
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
  "message":"Successfully uploaded image for user.",
  "data":{
    "full_name":"shopoth user",
    "email":"",
    "phone":"0185xxxxxxx",
    "images":{
      "app_img":"http://cdn.shopoth.net/variants/1cp9vgrf7g61plk0nq6g43afcqay/f9e93ed00f659178f5d9dd0219fa6f4534090099",
      "web_img":"http://cdn.shopoth.net/variants/1cp9vgrf7g61plk0nq6g43afcqay/033bd1b05feeb378fea3ab4eb5a34a6270"
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
   "message": "Unable to update user informations.",
   "data": {}
}
```
### Update a specific user's information.
___

* **URL :** `BASE_URL + /shop/api/v1/users`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "full_name": "shopoth user update"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully fetched user information.",
  "data":{
    "full_name":"shopoth user update",
    "email":"",
    "phone":"0185xxxxxxx",
    "gender":"xxx",
    "date_of_birth":"2022-08-29",
    "registered_at":"2022-09-01T10:51:59.066+06:00",
    "images":{"app_img":"","web_img":""},
    "addresses":[
      {"id":3057,
        "address_title":"others",
        "name":"ra","bn_name":null,
        "phone":"0185xxxxxxx","district_id":1,
        "thana_id":13,
        "area_id":4,
        "district_name":"Narshingdi",
        "district_bn_name":"Narshingdi",
        "thana_name":"Bogra",
        "thana_bn_name":"BN Bogra",
        "area_name":"Noapara",
        "area_bn_name":"নওয়াপাড়া",
        "address_line":"avc",
        "bn_address_line":null,
        "zip_code":null
      }],
    "favorite_stores":[
      {
        "partner_id":157,
        "name":"Shopoth Partner",
        "phone":"0176xxxxxxx",
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
          "address_line":"SP 1",
          "post_code":null
        },
        "reviews":{
          "rating_count":0,
          "rating_avg":0,
          "comments_count":0
        }
      }
    ],
    "cart":null,
    "whatsapp":"0185xxxxxxx",
    "viber":null,
    "imo":null,
    "preferred_name":"sp"
  }}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to update user informations",
   "data": {}
}
```
### My page password change.
___

* **URL :** `BASE_URL + /shop/api/v1/users/password`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "full_name": "shopoth user update"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully fetched user information.",
  "data":{
    "full_name":"shopoth user update",
    "email":"",
    "phone":"0185xxxxxxx",
    "gender":"xxx",
    "date_of_birth":"2022-08-29",
    "registered_at":"2022-09-01T10:51:59.066+06:00",
    "images":{"app_img":"","web_img":""},
    "addresses":[
      {"id":3057,
        "address_title":"others",
        "name":"ra","bn_name":null,
        "phone":"0185xxxxxxx",
        "district_id":1,
        "thana_id":13,
        "area_id":4,
        "district_name":"Narshingdi",
        "district_bn_name":"Narshingdi",
        "thana_name":"Bogra",
        "thana_bn_name":"BN Bogra",
        "area_name":"Noapara",
        "area_bn_name":"নওয়াপাড়া",
        "address_line":"avc",
        "bn_address_line":null,
        "zip_code":null
      }],
    "favorite_stores":[
      {
        "partner_id":157,
        "name":"Shopoth Partner",
        "phone":"0176xxxxxxx",
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
          "address_line":"SP 1",
          "post_code":null
        },
        "reviews":{
          "rating_count":0,
          "rating_avg":0,
          "comments_count":0
        }
      }
    ],
    "cart":null,
    "whatsapp":"0185xxxxxxx",
    "viber":null,
    "imo":null,
    "preferred_name":"sp"
  }}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to update user password",
   "data": {}
}
```
### Add address for user.
___

* **URL :** `BASE_URL + /shop/api/v1/users/address`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "address_line": "Dhaka",
  "area_id": 12,
  "district_id": 1,
  "name": "shopoth",
  "phone": "0185xxxxxx",
  "thana_id": 6,
  "title": "address shopoth",
  "zip_code": "1341"
}
```
* **Success Response**
* **Code :**`201`
* **Content :**
```json
{
  "success":true,
  "status":201,
  "message":"Successfully saved address.",
  "data":{
    "id":3123,
    "address_title":"address shopoth",
    "name":"shopoth user",
    "bn_name":null,
    "phone":"0185xxxxxx",
    "district_id":1,
    "thana_id":6,
    "area_id":12,
    "district_name":"Narshingdi",
    "district_bn_name":"Narshingdi",
    "thana_name":"kafrul 28",
    "thana_bn_name":"kafrul2",
    "area_name":"Bogra 00",
    "area_bn_name":"BN Bogra 00",
    "address_line":"Dhaka",
    "bn_address_line":null,
    "zip_code":"1341"
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
   "message": "Unable to save address",
   "data": {}
}
```
### Update address for user.
___

* **URL :** `BASE_URL + /shop/api/v1/users/address/:id`
* **Method :** `PUT`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "address_line": "Dhaka Bangladesh"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully updated address.",
  "data":{
    "id":3123,
    "address_title":"address shopoth",
    "name":"shopoth user",
    "bn_name":null,
    "phone":"0185xxxxxx",
    "district_id":1,
    "thana_id":6,
    "area_id":12,
    "district_name":"Narshingdi",
    "district_bn_name":"Narshingdi",
    "thana_name":"kafrul 28",
    "thana_bn_name":"kafrul2",
    "area_name":"Bogra 00",
    "area_bn_name":"BN Bogra 00",
    "address_line":"Dhaka Bangladesh",
    "bn_address_line":null,
    "zip_code":"1341"
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
   "message": "Unable to updated address",
   "data": {}
}
```
### Delete address of user.
___

* **URL :** `BASE_URL + /shop/api/v1/users/address/:id`
* **Method :** `DELETE`
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
  "status":201,
  "message":"Successfully deleted address.",
  "data":{}
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to deleted address",
   "data": {}
}
```
### Get all addresses of user.
___

* **URL :** `BASE_URL + /shop/api/v1/users/addresses`
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
  "message":"Successfully fetched user addresses.",
  "data":[
    {
      "id":3057,
      "address_title":"others",
      "name":"shopoth user",
      "bn_name":null,
      "phone":"0185xxxxxx",
      "district_id":1,
      "thana_id":13,
      "area_id":4,
      "district_name":"Narshingdi",
      "district_bn_name":"Narshingdi",
      "thana_name":"Bogra",
      "thana_bn_name":"BN Bogra",
      "area_name":"Noapara",
      "area_bn_name":"নওয়াপাড়া",
      "address_line":"avc",
      "bn_address_line":null,
      "zip_code":null
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
   "message": "Unable to fetch user addresses",
   "data": {}
}
```
### Add delivery preference
___

* **URL :** `BASE_URL + /shop/api/v1/users/delivery-preferences`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
    "shipping_type": "pick_up_point",
    "pay_type": "cash_on_delivery",
    "partner_id": 157
}   
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "id": 15,
  "user_id": 418,
  "partner_id": 157,
  "pay_type": "cash_on_delivery",
  "shipping_type": "pick_up_point",
  "created_at": "2022-12-21T20:37:43.553+06:00",
  "updated_at": "2022-12-21T20:37:43.553+06:00",
  "default": false
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "#{error}",
   "data": {}
}
```
### Show delivery preference
___

* **URL :** `BASE_URL + /shop/api/v1/users/delivery-preferences`
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
  "pick_up_point": [
    {
      "delivery_preference_id": 15,
      "pay_type": "cash_on_delivery",
      "shipping_type": "pick_up_point",
      "default": false,
      "partner_details": {
        "partner_name": "Shopoth Partner 1",
        "partner_phone": "0176xxxxxxxx",
        "partner_schedule": "Sat sun mon tues wed thurs",
        "slug": "shopoth-partner-1"
        "position": "https://www.google.com/maps/search/?api=1&query=,",
        "partner_address": {
          "area": "Bogra",
          "thana": "Abhaynagar",
          "district": "Narshingdi",
          "address_line": "SP 1",
          "post_code": null
        }
      }
    }
  ],
  "home_delivery": []
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "#{error}",
   "data": {}
}
```
### unable to fetch #{error}
___

* **URL :** `BASE_URL + /shop/api/v1/users/wallet`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
"0.00"
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "unable to fetch #{error}",
   "data": {}
}
```
### Fetch wallet amount
___

* **URL :** `BASE_URL + /shop/api/v1/users/wallet`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
"0.00"
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "unable to fetch #{error}",
   "data": {}
}
```
### Fetch User coupons
___

* **URL :** `BASE_URL + /shop/api/v1/users/coupons`
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
  "message": "Successfully fetched user coupons",
  "data": [
    {
      "id": 201042,
      "code": "SDM6QV",
      "discount_amount": "154.0",
      "is_used": false,
      "discount_type": "fixed",
      "max_limit": "0.0",
      "end_at": null
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
   "message": "unable to fetch #{error}",
   "data": {}
}
```
