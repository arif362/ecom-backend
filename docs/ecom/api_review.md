**Review API's**
----

Get all reviews

* **URL**: ``BASE_URL + /shop/api/v1/reviews``

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
[
  {
    "id": "",
    "title": "",
    "rating": "",
    "body": "",
    "user": {
      "user_name": ""
    },
    "is_approved": "",
    "review_type": "",
    "created_at": "",
    "updated_at": "",
    "product": {
      "product_title": ""
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

Create review for a product by a user

* **URL**: ``BASE_URL + /shop/api/v1/reviews``

* **Method:** `POST`

*  **URL Params:** `{
   "title": "",
   "body": "",
   "rating": "",
   "product_id": ""
   }`

* **Success Response:**
 ```json
{
  "id": "",
  "title": "",
  "body": "",
  "rating": "",
  "product_id": "",
  "user_id": "",
  "is_approved": "",
  "review_type": "",
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
Show all reviews for a product

* **URL**: ``BASE_URL + /shop/api/v1/reviews/product-review``

* **Method:** `GET`

*  **URL Params:** `"product_id": "" `

* **Success Response:**
 ```json
[
  {
    "id": "",
    "title": "",
    "rating": "",
    "body": "",
    "user": {
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
          { "message": "Can not show due to...", "status_code": 500 }
         ```

Update a review of a product

* **URL**: ``BASE_URL + /shop/api/v1/reviews/:id``

* **Method:** `PUT`

*  **URL Params:** `{
   "title": "",
   "body": "",
   "rating": "",
   "product_id": "",
   "review_type": ""
}`

* **Success Response:**
 ```json
{
  "id": "",
  "title": "",
  "body": "",
  "rating": "",
  "product_id": "",
  "user_id": "",
  "is_approved": "",
  "review_type": "",
  "created_at": "",
  "updated_at": ""
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Can not update due to", "status_code": 500 }
         ```

delete a review of a product

* **URL**: ``BASE_URL + /shop/api/v1/reviews/:id``

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
 