**Cart APIs**
----

### Get all shopoth_line_item in cart for ecommerce:

* **URL**: `BASE_URL + /shop/api/v1/carts/103046?warehouse_id=5`

* **Method:** `GET`

* **Authentication**
  `Auth optional`

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "সফলভাবে কার্টের বিবরণ আনা হয়েছে ।",
  "data": {
    "cart_id": 103046,
    "sub_total": "170.0",
    "total_items": 5,
    "cart_discount": 0,
    "cart_discount_type": null,
    "total_price": 170,
    "min_cart_value": 180,
    "shipping_charges": {
      "pick_up_point": 0,
      "home_delivery": 100,
      "express_delivery": 70
    },
    "coupon_code": null,
    "tenures": [3, 6, 9],
    "is_emi_available": true,
    "shopoth_line_items": [
      {
        "id": 147234,
        "quantity": 5,
        "price": "34.0",
        "unit_price": 34,
        "sub_total": 170,
        "discount_amount": 0,
        "sample_for": null,
        "returned_quantity": 0,
        "refundable": true,
        "returnable": false,
        "variant_id": 6356,
        "product_id": 5613,
        "product_title": "Lifebuoy Skin Cleansing Bar Cool Fresh 100g (Free Lifebuoy Turmeric and honey 25gm)",
        "product_bn_title": "লাইফবয় স্কিন ক্লিনসিং বার কুল ফ্রেশ ১০০ গ্রাম (ফ্রি লাইফবইয় টার্মারিক অ্যান্ড হানি- ২৫ গ্রাম)",
        "max_quantity_per_order": 0,
        "product_slug": "lifebuoy-skin-cleansing-bar-cool-fresh-100g-free-lifebuoy-turmeric-and-honey-25gm",
        "product_image": "http://cdn.shopoth.net/abmnlouli6tyzsk1pn9qpwzq034i",
        "product_attribute": [],
        "is_reviewed": false,
        "is_sample": false,
        "is_available": false,
        "is_limit_exceeded": false
      }
    ]
  }
}
```

* **Code:** `200`
    * **Error Response:**
        * **Code:** `422`
        * **Content(example):**
             ```json 
          {
             "success": false,
             "status": 200,
             "message": "Unable to fetch details of cart.",
             "data": {}
          }
           ```
