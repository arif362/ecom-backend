**Store Info API's**
----

Create Static Page

* **URL**: ``BASE_URL + /shop/api/v1/static_pages/``

* **Method:** `POST`

*  **URL Params:** `{
   "official_email": "",
   "contact_address": "",
   "contact_number": "",
   "footer_bottom": ""
   }`

* **Success Response:**
 ```json
{
  "id": "",
  "official_email": "",
  "contact_address": "",
  "contact_number": "",
  "footer_bottom": "",
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
   "official_email": "",
   "contact_address": "",
   "contact_number": "",
   "footer_bottom": ""
}`

* **Success Response:**
 ```json
{
  "id": "",
  "official_email": "",
  "contact_address": "",
  "contact_number": "",
  "footer_bottom": "",
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
  "id": "",
  "official_email": "",
  "contact_address": "",
  "contact_number": "",
  "footer_bottom": "",
  "created_at": "",
  "updated_at": ""
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
  "official_email": "",
  "contact_address": "",
  "contact_number": "",
  "footer_bottom": "",
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