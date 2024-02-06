**Product Category & Filters**
----
### -> Get all product in a category
* **URL**: `BASE_URL + /api/v1/product_category/:id`

* **Method:** `GET`
  
* **REQUEST HEADER**
`{"Content-Type": "application/json"}`

* **Success(example):**
 ```json
{
  "category": {
    "id": 1,
    "title": "Basic",
    "bn_title": "adsaldka",
    "image": ""
  },
  "product_category": [
    {
      "id": 2,
      "title": "PenDrive",
      "bn_title": "PenDrive",
      "image": "",
      "product_price": null,
      "product_rating": "no rating"
    }
  ]
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`, `422`, `404`
    * **Content(example):**
         ```json 
          { "message": "Error detail", 500 }
         ```

### -> Filter Products based on a category
* **URL**: `BASE_URL + /api/v1/product_category/:id/filter`

* **Method:** `GET`

* **URL Params:**
  `{ "min_price": "100.5"/"5000"", 
  "max_price(optiona)": "1100"/"9999.99""}`
  _If max_price is not present 
  it will be the same as the min_price_.
 
 
* **REQUEST HEADER**
  `{"Content-Type": "application/json"}`

* **Success(example):**
 ```json
[
  {
    "id": 2,
    "title": "PenDrive",
    "bn_title": "PenDrive",
    "image": "",
    "product_price": null,
    "product_rating": "no rating"
  }
]
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`, `422`, `404`
    * **Content(example):**
         ```json 
          { "message": "Error detail", 500 }
         ```
