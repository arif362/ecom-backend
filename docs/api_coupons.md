### Coupon Check
___

* **URL :** `BASE_URL + /api/v1/coupons/check`
* **Method :** `GET`
* **URL Params :**
```json
{
  "code": "XXX111"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "is_exist": false,
  "message": "unique coupon"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "is_exist": true,
  "message": "already exists"
}
```
### Coupon Create
___

* **URL :** `BASE_URL + /api/v1/coupons`
* **Method :** `POST`
* **URL Params :**
```json   
{
    "is_visible": true,
    "code": "cat111",
    "discount_amount":5,
    "start_at": "2022-011-05",
    "end_at": "2022-12-25",
    "coupon_type": "multi_user",
    "is_active": true,
    "discount_type": "percentage",
    "max_limit": 300,
    "max_user_limit": 20,
    "used_count": 2,
    "skus": "kitkat",
    "phone_numbers": "018571234566",
    "is_visible": true,
    "coupon_category_attributes": {
        "category_inclusion_type": "include",
        "category_ids":[18]
    }
    
} 
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
   "success": false,
   "status": 200,
   "message": "Successfully created coupon",
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
   "message": "Unable to create coupon",
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
    "message": "Must provide category inclusion type to create coupon with category",
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
    "message": "Only multi-user coupon can have category",
    "data": {}
}
```
### First Registration and Multiple User Coupon List
___
* **URL :** `BASE_URL + /api/v1/coupons`
* **Method :** `GET`
* **URL Params :**
```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
   "success": false,
   "status": 200,
   "message": "Successfully fetched coupons",
   "data": [
     {
       "id": 1,
       "coupon_code": "abc123",
       "discount_amount": 20,
       "start_at": "2022-02-05T06:00:00.000+06:00",
       "end_at": "2022-02-20T06:00:00.000+06:00",
       "is_used": false,
       "customer_id": null,
       "customer_order_id": null,
       "promotion_id": null,
       "cart_value": null,
       "coupon_type": "first_registration",
       "is_active" : true,
       "discount_type": "percentage",
       "max_limit": "500.0",
       "max_user_limit": 20,
       "used_count": 3,
       "skus": "sku1, sku2,  sku3"
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
   "message": "Unable to fetch coupon list",
   "data": {}
}
```
### Coupon Details
___
* **URL :** `BASE_URL + /api/v1/coupons/:id`
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
    "message": "Successfully fetched coupon",
    "data": {
        "id": 200774,
        "coupon_code": "CAT111",
        "discount_amount": 5,
        "start_at": "2022-05-11T06:00:00.000+06:00",
        "end_at": "2022-12-25T06:00:00.000+06:00",
        "is_used": false,
        "customer_id": null,
        "customer_order_id": null,
        "promotion_id": null,
        "cart_value": null,
        "coupon_type": "multi_user",
        "is_active": true,
        "discount_type": "percentage",
        "max_limit": "300.0",
        "max_user_limit": 20,
        "used_count": 2,
        "skus": "kitkat",
        "phone_numbers": "018571234566",
        "created_by": {
            "id": 106,
            "name": "central_admin"
        },
        "is_visible": true,
        "coupon_categories": {
            "id": 23,
            "category_inclusion_type": "included",
            "categories": [
                {
                    "id": 18,
                    "title": "Snack and Beveragess"
                },
                {
                    "id": 21,
                    "title": "Health & Hygiene"
                }
            ]
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
   "message": "Unable to fetch coupon details",
   "data": {}
}
```
### Coupon Update
___

* **URL :** `BASE_URL + /api/v1/coupons/:id`
* **Method :** `PUT`
* **URL Params :**
```json
{
  "code": "abc123",
  "discount_amount": 100,
  "start_at": "2022-02-05",
  "end_at": "2022-02-20",
  "is_active": false,
  "discount_type": "percentage",
  "max_limit": "500.0",
  "max_user_limit": 20,
  "used_count": 3,
  "skus": "sku2,  sku3"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
   "success": false,
   "status": 200,
   "message": "Successfully updated coupon",
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
   "message": "Unable to update coupon due to: #{error.message}",
   "data": {}
}
```
### Coupon Delete
___

* **URL :** `BASE_URL + /api/v1/coupons/:id`
* **Method :** `DELETE`
* **URL Params :**
```json

```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
   "success": false,
   "status": 200,
   "message": "Successfully deleted coupon",
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
   "message": "Unable to delete coupon",
   "data": {}
}
```
