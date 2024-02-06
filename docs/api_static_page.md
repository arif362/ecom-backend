**Static Page API's**
----

Get all information of Static Page

* **URL**: ``BASE_URL + /shop/api/v1/static_pages/all-pages``

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
[{
  "id": "",
  "title": "",
  "body": "",
  "slug": "",
  "is_active": "",
  "show_in_footer": "",
  "position": "",
  "created_at": "",
  "updated_at": ""
}
]
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Something went wrong", "status_code": 500 }
         ```

Create Static Page

* **URL**: ``BASE_URL + /shop/api/v1/static_pages/``

* **Method:** `POST`

*  **URL Params:** `{
   "title": "",
   "position": "",
   "body": "",
   show_in_footer: "",
   is_active: ""
   }`

* **Success Response:**
 ```json
{
  "id": "",
  "title": "",
  "body": "",
  "slug": "",
  "is_active": "",
  "show_in_footer": "",
  "position": "",
  "created_at": "",
  "updated_at": ""
}
```

* **Code:** `201`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Can not create due to", "status_code": 500 }
         ```
Update info in static page
* **URL**: ``BASE_URL + /shop/api/v1/static_pages/:id/update``

* **Method:** `PUT`

*  **URL Params:** `{

"id": "",
"title": "",
"body": "",
"slug": "",
"is_active": "",
"show_in_footer": "",
"position": "",
"created_at": "",
"updated_at": ""
}`

* **Success Response:**
 ```json
{
  "id": "",
  "title": "",
  "body": "",
  "slug": "",
  "is_active": "",
  "show_in_footer": "",
  "position": "",
  "created_at": "",
  "updated_at": ""
}

```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Something went wrong", "status_code": 500 }
         ```
 
Show information of Static Page

* **URL**: ``BASE_URL + /shop/api/v1/static_pages/:id/show``

* **Method:** `GET`

*  **URL Params:** `{"id": "" }`

* **Success Response:**
 ```json
{
  "title": "",
  "body": "",
  "published_at": ""
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Can not show due to", "status_code": 500 }
         ``` 
      

Delete static page

* **URL**: ``BASE_URL + /shop/api/v1/static_pages/:id``

* **Method:** `DELETE`

*  **URL Params:** `{ "id": ""}`

* **Success Response:**
 ```json
{

  "id": "",
  "title": "",
  "body": "",
  "slug": "",
  "is_active": "",
  "show_in_footer": "",
  "position": "",
  "created_at": "",
  "updated_at": ""
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "", "status_code": 500 }
         ```