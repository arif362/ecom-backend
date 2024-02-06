### Create a cart
___

* **URL :** `BASE_URL + /shop/api/v1/carts`

* **Method :** `POST`

* **URL Params :**

```json
{
  "warehouse_id": 8,
  "variant_id":   10220,
  "quantity": 2
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully created cart.",
  "data": {
    "cart_id": 138554,
    "sub_total": "1271.0",
    "total_items": 3,
    "cart_discount": 0,
    "cart_discount_type": null,
    "total_price": 1271,
    "min_cart_value": 180,
    "shipping_charges": {
      "pick_up_point": 0,
      "express_delivery": 70,
      "home_delivery": 50
    },
    "coupon_code": null,
    "shopoth_line_items": [
      {
        "id": 220722,
        "quantity": 2,
        "price": "440.0",
        "unit_price": 388,
        "sub_total": 776,
        "discount_amount": 104,
        "sample_for": null,
        "returned_quantity": 0,
        "refundable": true,
        "returnable": false,
        "variant_id": 10220,
        "product_id": 8284,
        "product_title": "Tresemme Shampoo Keratin Smooth 340ml",
        "product_bn_title": "ট্রেসেমে শ্যাম্পু কেরাটিন স্মুথ ৩৪০ মিলি",
        "max_quantity_per_order": 0,
        "product_slug": "tresemme-shampoo-keratin-smooth-340ml",
        "product_image": "https://cdn.shopoth.net/s3tbtxve2dqll2bekwuvaxsd3m08",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": true,
        "is_limit_exceeded": false
      },
      {
        "id": 186270,
        "quantity": 1,
        "price": "495.0",
        "unit_price": 495,
        "sub_total": 495,
        "discount_amount": 0,
        "sample_for": null,
        "returned_quantity": 0,
        "refundable": true,
        "returnable": false,
        "variant_id": 4904,
        "product_id": 4302,
        "product_title": "Nescafe Classic Coffee Jar 200g",
        "product_bn_title": "নেসক্যাফে ক্লাসিক কফি জার ২০০ গ্রাম",
        "max_quantity_per_order": 0,
        "product_slug": "nescafe-classic-coffee-jar-200g",
        "product_image": "https://cdn.shopoth.net/risoilfwicxw6ieffzvgvd6vv5on",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": true,
        "is_limit_exceeded": false
      }
    ],
    "tenures": [
      3
    ],
    "is_emi_available": false
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
   "message": "Unable to create cart",
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
  "message": "Unable to find this product.",
  "data": {}
}
```
### Add Product to a cart
___

* **URL :** `BASE_URL + /shop/api/v1/carts/:id/shopoth_line_items`

* **Method :** `PUT`

* **URL Params :**

```json
{
  "warehouse_id": 8,
  "variant_id":   2,
  "quantity": 1
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully updated line item.",
  "data": {
    "cart_id": 138554,
    "sub_total": "1336.0",
    "total_items": 4,
    "cart_discount": 0,
    "cart_discount_type": null,
    "total_price": 1336,
    "min_cart_value": 180,
    "shipping_charges": {
      "pick_up_point": 0,
      "express_delivery": 70,
      "home_delivery": 50
    },
    "coupon_code": null,
    "shopoth_line_items": [
      {
        "id": 220723,
        "quantity": 1,
        "price": "65.0",
        "unit_price": 65,
        "sub_total": 65,
        "discount_amount": 0,
        "sample_for": null,
        "returned_quantity": 0,
        "refundable": true,
        "returnable": false,
        "variant_id": 2,
        "product_id": 2,
        "product_title": "Freedom Pregnancy Test Cassette",
        "product_bn_title": "ফ্রিডম প্রেগনেনসি টেস্ট ক্যাসেট",
        "max_quantity_per_order": 5,
        "product_slug": "freedom-pregnancy-test-cassette",
        "product_image": "https://cdn.shopoth.net/ktb6kg4inf70zy7si24hgfhyk68i",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": true,
        "is_limit_exceeded": false
      },
      {
        "id": 220722,
        "quantity": 2,
        "price": "440.0",
        "unit_price": 388,
        "sub_total": 776,
        "discount_amount": 104,
        "sample_for": null,
        "returned_quantity": 0,
        "refundable": true,
        "returnable": false,
        "variant_id": 10220,
        "product_id": 8284,
        "product_title": "Tresemme Shampoo Keratin Smooth 340ml",
        "product_bn_title": "ট্রেসেমে শ্যাম্পু কেরাটিন স্মুথ ৩৪০ মিলি",
        "max_quantity_per_order": 0,
        "product_slug": "tresemme-shampoo-keratin-smooth-340ml",
        "product_image": "https://cdn.shopoth.net/s3tbtxve2dqll2bekwuvaxsd3m08",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": true,
        "is_limit_exceeded": false
      },
      {
        "id": 186270,
        "quantity": 1,
        "price": "495.0",
        "unit_price": 495,
        "sub_total": 495,
        "discount_amount": 0,
        "sample_for": null,
        "returned_quantity": 0,
        "refundable": true,
        "returnable": false,
        "variant_id": 4904,
        "product_id": 4302,
        "product_title": "Nescafe Classic Coffee Jar 200g",
        "product_bn_title": "নেসক্যাফে ক্লাসিক কফি জার ২০০ গ্রাম",
        "max_quantity_per_order": 0,
        "product_slug": "nescafe-classic-coffee-jar-200g",
        "product_image": "https://cdn.shopoth.net/risoilfwicxw6ieffzvgvd6vv5on",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": true,
        "is_limit_exceeded": false
      }
    ],
    "tenures": [
      3
    ],
    "is_emi_available": false
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
   "message": "Can't add due to unavailable quantity",
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
  "message": "Unable to update line item",
  "data": {}
}
```
### Delete Product from a cart
___

* **URL :** `BASE_URL + /shop/api/v1/carts/:id/shopoth_line_items/:shopoth_line_item_id`

* **Method :** `DELETE`

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
    "success": true,
    "status": 200,
    "message": "Successfully deleted item from cart.",
    "data": {
        "cart_id": 138554,
        "sub_total": "1271.0",
        "total_items": 3,
        "cart_discount": 0,
        "cart_discount_type": null,
        "total_price": 1271,
        "min_cart_value": 180,
        "shipping_charges": {
            "pick_up_point": 0,
            "express_delivery": 70,
            "home_delivery": 50
        },
        "coupon_code": null,
        "shopoth_line_items": [
            {
                "id": 220722,
                "quantity": 2,
                "price": "440.0",
                "unit_price": 388,
                "sub_total": 776,
                "discount_amount": 104,
                "sample_for": null,
                "returned_quantity": 0,
                "refundable": true,
                "returnable": false,
                "variant_id": 10220,
                "product_id": 8284,
                "product_title": "Tresemme Shampoo Keratin Smooth 340ml",
                "product_bn_title": "ট্রেসেমে শ্যাম্পু কেরাটিন স্মুথ ৩৪০ মিলি",
                "max_quantity_per_order": 0,
                "product_slug": "tresemme-shampoo-keratin-smooth-340ml",
                "product_image": "https://cdn.shopoth.net/s3tbtxve2dqll2bekwuvaxsd3m08",
                "product_attribute": [],
                "is_reviewed": false,
                "is_sample": false,
                "is_available": true,
                "is_limit_exceeded": false
            },
            {
                "id": 186270,
                "quantity": 1,
                "price": "495.0",
                "unit_price": 495,
                "sub_total": 495,
                "discount_amount": 0,
                "sample_for": null,
                "returned_quantity": 0,
                "refundable": true,
                "returnable": false,
                "variant_id": 4904,
                "product_id": 4302,
                "product_title": "Nescafe Classic Coffee Jar 200g",
                "product_bn_title": "নেসক্যাফে ক্লাসিক কফি জার ২০০ গ্রাম",
                "max_quantity_per_order": 0,
                "product_slug": "nescafe-classic-coffee-jar-200g",
                "product_image": "https://cdn.shopoth.net/risoilfwicxw6ieffzvgvd6vv5on",
                "product_attribute": [],
                "is_reviewed": false,
                "is_sample": false,
                "is_available": true,
                "is_limit_exceeded": false
            }
        ],
        "tenures": [
            3
        ],
        "is_emi_available": false
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
  "message": "Unable to remove Shopoth line Item",
  "data": {}
}
```
### Add by one quantity of a product of the cart
___

* **URL :** `BASE_URL + /shop/api/v1/carts/:id/shopoth_line_items/:shopoth_line_item_id/add_one`

* **Method :** `PUT`

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
  "success": true,
  "status": 200,
  "message": "Added one quantity.",
  "data": {
    "cart_id": 138554,
    "sub_total": "1659.0",
    "total_items": 4,
    "cart_discount": 0,
    "cart_discount_type": null,
    "total_price": 1659,
    "min_cart_value": 180,
    "shipping_charges": {
      "pick_up_point": 0,
      "express_delivery": 70,
      "home_delivery": 50
    },
    "coupon_code": null,
    "shopoth_line_items": [
      {
        "id": 220722,
        "quantity": 3,
        "price": "440.0",
        "unit_price": 388,
        "sub_total": 1164,
        "discount_amount": 156,
        "sample_for": null,
        "returned_quantity": 0,
        "refundable": true,
        "returnable": false,
        "variant_id": 10220,
        "product_id": 8284,
        "product_title": "Tresemme Shampoo Keratin Smooth 340ml",
        "product_bn_title": "ট্রেসেমে শ্যাম্পু কেরাটিন স্মুথ ৩৪০ মিলি",
        "max_quantity_per_order": 0,
        "product_slug": "tresemme-shampoo-keratin-smooth-340ml",
        "product_image": "https://cdn.shopoth.net/s3tbtxve2dqll2bekwuvaxsd3m08",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": true,
        "is_limit_exceeded": false
      },
      {
        "id": 186270,
        "quantity": 1,
        "price": "495.0",
        "unit_price": 495,
        "sub_total": 495,
        "discount_amount": 0,
        "sample_for": null,
        "returned_quantity": 0,
        "refundable": true,
        "returnable": false,
        "variant_id": 4904,
        "product_id": 4302,
        "product_title": "Nescafe Classic Coffee Jar 200g",
        "product_bn_title": "নেসক্যাফে ক্লাসিক কফি জার ২০০ গ্রাম",
        "max_quantity_per_order": 0,
        "product_slug": "nescafe-classic-coffee-jar-200g",
        "product_image": "https://cdn.shopoth.net/risoilfwicxw6ieffzvgvd6vv5on",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": true,
        "is_limit_exceeded": false
      }
    ],
    "tenures": [
      3
    ],
    "is_emi_available": false
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
  "message": "Unable to increase quantity",
  "data": {}
}
```
### Decrease by one quantity of a product of the cart
___

* **URL :** `BASE_URL + /shop/api/v1/carts/:id/shopoth_line_items/:shopoth_line_item_id/dec_one`

* **Method :** `PUT`

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
  "success": true,
  "status": 200,
  "message": "Decreased one quantity.",
  "data": {
    "cart_id": 138554,
    "sub_total": "1271.0",
    "total_items": 3,
    "cart_discount": 0,
    "cart_discount_type": null,
    "total_price": 1271,
    "min_cart_value": 180,
    "shipping_charges": {
      "pick_up_point": 0,
      "express_delivery": 70,
      "home_delivery": 50
    },
    "coupon_code": null,
    "shopoth_line_items": [
      {
        "id": 220722,
        "quantity": 2,
        "price": "440.0",
        "unit_price": 388,
        "sub_total": 776,
        "discount_amount": 104,
        "sample_for": null,
        "returned_quantity": 0,
        "refundable": true,
        "returnable": false,
        "variant_id": 10220,
        "product_id": 8284,
        "product_title": "Tresemme Shampoo Keratin Smooth 340ml",
        "product_bn_title": "ট্রেসেমে শ্যাম্পু কেরাটিন স্মুথ ৩৪০ মিলি",
        "max_quantity_per_order": 0,
        "product_slug": "tresemme-shampoo-keratin-smooth-340ml",
        "product_image": "https://cdn.shopoth.net/s3tbtxve2dqll2bekwuvaxsd3m08",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": true,
        "is_limit_exceeded": false
      },
      {
        "id": 186270,
        "quantity": 1,
        "price": "495.0",
        "unit_price": 495,
        "sub_total": 495,
        "discount_amount": 0,
        "sample_for": null,
        "returned_quantity": 0,
        "refundable": true,
        "returnable": false,
        "variant_id": 4904,
        "product_id": 4302,
        "product_title": "Nescafe Classic Coffee Jar 200g",
        "product_bn_title": "নেসক্যাফে ক্লাসিক কফি জার ২০০ গ্রাম",
        "max_quantity_per_order": 0,
        "product_slug": "nescafe-classic-coffee-jar-200g",
        "product_image": "https://cdn.shopoth.net/risoilfwicxw6ieffzvgvd6vv5on",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": true,
        "is_limit_exceeded": false
      }
    ],
    "tenures": [
      3
    ],
    "is_emi_available": false
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
  "message": "Unable to decrease quantity",
  "data": {}
}
```
### Delete the cart
___

* **URL :** `BASE_URL + /shop/api/v1/carts/:id/`

* **Method :** `DELETE`

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
  "success": true,
  "status": 200,
  "message": "Successfully deleted cart.",
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
  "message": "Unable to delete cart",
  "data": {}
}
```


