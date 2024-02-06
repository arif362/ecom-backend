**Apply Coupon**
----

* **URL**: ``BASE_URL + shop/api/v1/coupon/apply``
* **Method:** `PUT`
* * **Header :** `Auth Token`
* **Params:**
```json
{
  "area_id":"",
  "coupon_code": "SKU111",
  "cart_id": 11034,
  "warehouse_id": 49,
  "district_id": 3,
  "order_type": "organic",
  "partner_id": "",
  "thana_id": ""
}
```
* **Success Response:**
  * **Code:** `200`
```json
 {
    "success": true,
    "status": 200,
    "message": "The coupon is applied successfully.",
    "data": {
        "cart_id": 11034,
        "sub_total": "4850.0",
        "total_items": 1,
        "cart_discount": 485,
        "cart_discount_type": "abs",
        "total_price": 4365,
        "min_cart_value": 180,
        "shipping_charges": {
            "pick_up_point": 0,
            "home_delivery": 100,
            "express_delivery": 70
        },
        "coupon_code": "SKU111",
        "shopoth_line_items": [
            {
                "id": 15422,
                "quantity": 1,
                "price": "5000.0",
                "unit_price": 4850,
                "sub_total": 4850,
                "discount_amount": 150,
                "sample_for": null,
                "returned_quantity": 0,
                "refundable": true,
                "returnable": false,
                "variant_id": 2954,
                "product_id": 3860,
                "product_title": "Kitkat",
                "product_bn_title": "কিটকেট",
                "max_quantity_per_order": 0,
                "product_slug": "শীর্ষ-খবর",
                "product_image": "http://cdn.shopoth.net/wzsq3qjcfhfog8ux4isks4dgq5y0",
                "product_attribute": [],
                "is_reviewed": false,
                "is_sample": false,
                "is_available": true,
                "is_limit_exceeded": false
            }
        ],
        "tenures": [
            3,
            6,
            9,
            12,
            18,
            24,
            36
        ],
        "is_emi_available": false
    }
}
```
* **Error Response**
* **Code :**`406`
* **Content :**
```json
{
  "success": false,
  "status": 406,
  "message": "This coupon is already used or invalid!",
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
  "message": "Unable to apply coupon",
  "data": {}
}
```
**Remove Coupon**
----

* **URL**: ``BASE_URL + shop/api/v1/coupon/remove``
* **Method:** `PUT`
* * **Header :** `Auth Token`
* **Params:**
```json
{
  "coupon_code": "SKU111",
  "cart_id": 11034,
  "warehouse_id": 49
}
```
* **Success Response:**
  * **Code:** `200`
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully coupon removed.",
  "data": {
    "cart_id": 11034,
    "sub_total": "4850.0",
    "total_items": 1,
    "cart_discount": 0,
    "cart_discount_type": null,
    "total_price": 4850,
    "min_cart_value": 180,
    "shipping_charges": {
      "pick_up_point": 0,
      "home_delivery": 100,
      "express_delivery": 70
    },
    "coupon_code": null,
    "shopoth_line_items": [
      {
        "id": 15422,
        "quantity": 1,
        "price": "5000.0",
        "unit_price": 4850,
        "sub_total": 4850,
        "discount_amount": 150,
        "sample_for": null,
        "returned_quantity": 0,
        "refundable": true,
        "returnable": false,
        "variant_id": 2954,
        "product_id": 3860,
        "product_title": "Kitkat",
        "product_bn_title": "কিটকেট",
        "max_quantity_per_order": 0,
        "product_slug": "শীর্ষ-খবর",
        "product_image": "http://cdn.shopoth.net/wzsq3qjcfhfog8ux4isks4dgq5y0",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": true,
        "is_limit_exceeded": false
      }
    ],
    "tenures": [
      3,
      6,
      9,
      12,
      18,
      24,
      36
    ],
    "is_emi_available": false
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
  "message": "This coupon is not applied on the cart.",
  "data": {}
}
```