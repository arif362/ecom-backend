**Homepage API's**
----
Create category

* **URL**: ``BASE_URL + /api/v1/products``

* **Method:** `POST`

*  **URL Params:**
   `{ "title": "smartphone",
      "bn_title": "smartphone",
      "description": "Mobile phones are now part of our lives as they are not just utilized for sending texts or making phone calls.",
      "image": "https://www.daraz.com.bd/products/samsung-galaxy-note-20-ultra-69-1440x3088-pixels-108mp-camera-12gb-ram-exynos-990-4500-mah-battery-i134710726-s1056614065.html?spm=a2a0e.searchlistcategory.list.30.274d585eQMx6Qo&search=1",
      "parent_id": 1,
      "home_page_visibility": 1
   }`

Get all categories

* **URL**: ``BASE_URL + /api/v1/categories``

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
`{
  "categories": [
    {
      "id": 1,
      "titley": "Category 1",
      "bn_title": "BN Category 1",
      "description": null,
      "bn_description": null,
      "image": null,
      "home_page_visibility": true,
      "sub_categories": []
    },
    {
      "id": 2,
      "titley": "Mobile",
      "bn_title": "fhone",
      "description": null,
      "bn_description": null,
      "image": null,
      "home_page_visibility": true,
      "sub_categories": [
        {
          "id": 3,
          "title": "Nokia",
          "bn_title": "nokie",
          "description": null,
          "bn_description": null,
          "image": null,
          "home_page_visibility": true
        }
      ]
    }
  ]
}`

* **Code:** `200`
* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```

Get a category

* **URL**: ``BASE_URL + /api/v1/categories/:id``

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```
Update a category

* **URL**: ``BASE_URL + /api/v1/categories/:id``

* **Method:** `PUT`

*  **URL Params:** `None`

* **Success Response:**
 ```json
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```
    
Delete a category

* **URL**: ``BASE_URL + /api/v1/categories/:id``

* **Method:** `DELETE`

*  **URL Params:** `None`

* **Success Response:**
 ```json
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```

### Category list with sub-category without pagination
___

* **URL :** `BASE_URL + /api/v1/categories/tree_details`

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
    "message": "Successfully fetched categories",
    "data":
        {
            "key": 432,
            "title": "Root Category",
            "children": [
                {
                    "key": 433,
                    "title": "Baby root",
                    "children": [
                        {
                            "key": 434,
                            "title": "baby baby root",
                            "children": [
                                {
                                    "key": 435,
                                    "title": "Baby Baby Baby Root",
                                    "children": []
                                }
                            ]
                        },
                        {
                            "key": 438,
                            "title": "dd",
                            "children": []
                        }
                    ]
                }
            ]
        }
      ]
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch categories",
   "data": {}
}
```
