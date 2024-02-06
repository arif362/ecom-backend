**Wishlist API's**
----

Get all wishlist

* **URL**: ``BASE_URL + /shop/api/v1/wishlists``

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
[
  {
    "id": "",
    "product": {
      "product_id": "",
      "title": "",
      "quantity": ""
    },
    "created_at": "",
    "updated_at": "",
    "user": {
      "user_id": "",
      "email": "",
      "user_name": ""
    }
  }
]
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Something went wrong due to...", "status_code": 500 }
         ```

Create wishlist for a product by a user

* **URL**: ``BASE_URL + /shop/api/v1/wishlists``

* **Method:** `POST`

*  **URL Params:** `{
   "product_id": ""
   }`

* **Success Response:**
 ```json
{
  "id": "",
  "product_id": "",
  "user_id": "",
  "created_at": "",
  "updated_at": ""
}
```

* **Code:** `201`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Can not create due to...", "status_code": 500 }
         ```
See wishlist by user

* **URL**: ``BASE_URL + /shop/api/v1/wishlists/my-wishlist``

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
[
  {
    "id": "",
    "product": {
      "product_id": "",
      "title": "",
      "quantity": ""
    }
  }
]
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Can not show due to...", "status_code": 500 }
         ```

delete a wishlist of a product

* **URL**: ``BASE_URL + /shop/api/v1/wishlists/:id``

* **Method:** `DELETE`

*  **URL Params:** `{
   "id": ""
   }`

* **Success Response:**
 ```json
{
  "message": "Successful",
  "status_code": 200
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Can not delete due to...", "status_code": 500 }
 