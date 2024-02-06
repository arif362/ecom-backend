**ADD_to_Cart API's**
----

Add variant of product to cart using shopoth_line_items

* **URL**: ``BASE_URL + /shop/api/v1/shopoth_line_items/``

* **Method:** `POST`

*  **URL Params:** `{ cart_id: '',
                      variant_id: ''
                      }`

* **Success Response:**
 ```json
{
    "shopoth_line_item": {
            "id": "",
            "cart_id": "",
            "customer_order_id": null,
            "quantity": 1,
            "price": "",
            "created_at": "2020-12-12T07:44:53.726Z",
            "updated_at": "2020-12-12T07:44:53.726Z",
            "variant_id": ""
        }
}
```

  * **Code:** `200`
* **Error Response:**
  * **Code:** `500`
  * **Content:**
       ```json
        { "message": "Something went wrong!", "status_code": 500 }
       ```
Add quantity of variant in cart

* **URL**: ``BASE_URL + /shop/api/v1/shopoth_line_items/:id``

* **Method:** `PUT`

*  **URL Params:** `{ id: '' }`

* **Success Response:**
 ```json
{
   "cart_id": "",
}
```

  * **Code:** `200`
* **Error Response:**
  * **Code:** `500`
  * **Content:**
       ```json
        { "message": "Something went wrong!", "status_code": 500 }
       ```
Decrease quantity of variant in cart

* **URL**: ``BASE_URL + /shop/api/v1/shopoth_line_items/:id``

* **Method:** `PUT`

*  **URL Params:** `{ id: '' }`

* **Success Response:**
 ```json
{
    "cart_id": "",
}
```

  * **Code:** `200`
* **Error Response:**
  * **Code:** `500`
  * **Content:**
       ```json
        { "message": "Must keep one product", "status_code": 400 }
       ```
Delete item from cart

* **URL**: ``BASE_URL + /shop/api/v1/shopoth_line_items/:id``

* **Method:** `DELETE`

*  **URL Params:** `{ id: "" }`

* **Success Response:**
 ```json
   { "message": "Deleted", "status_code": 200 }
```

  * **Code:** `200`
* **Error Response:**
  * **Code:** `500`
  * **Content:**
       ```json
        { "message": "Not Deleted", "status_code": 500 }
       ```
See all items in cart

* **URL**: ``BASE_URL + /shop/api/v1/carts/:id/my-cart``

* **Method:** `GET`

*  **URL Params:** `{ id: '' }`

* **Success Response:**
 ```json
{
            "id": "",
            "quantity": "",
            "price": "",
            "total_price": "",
            "variant": {
                "variant_id": "",
                "variant_sku": "",
                "product_id": "",
                "product_title": ""
            },
            "cart": {
                "cart_id": "",
                "item_count": "" ,
                "sub_total": ""
            }
}
```

  * **Code:** `200`
* **Error Response:**
  * **Code:** `500`
  * **Content:**
       ```json
        { "message": "Something went wrong!", "status_code": 500 }
       ```