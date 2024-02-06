**Social Link API's**
----

Add Social Link

* **URL**: ``BASE_URL + /shop/api/v1/social_links/``

* **Method:** `POST`

*  **URL Params:** `{
   "name": "",
   "url": ""
   }`

* **Success Response:**
 ```json
{
  "id": "",
  "name": "",
  "url": "",
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
Update info of social link
* **URL**: ``BASE_URL + /shop/api/v1/social_links/:id/update``

* **Method:** `PUT`

*  **URL Params:** `{
   "name": "",
   "url": ""
   }`

* **Success Response:**
 ```json
{
  "id": "",
  "name": "",
  "url": "",
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

Show information of Static Page

* **URL**: ``BASE_URL + /shop/api/v1/social_links/:id/show``

* **Method:** `GET`

*  **URL Params:** `{"id": "" }`

* **Success Response:**
 ```json
{
  "id": "",
  "name": "",
  "url": "",
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

* **URL**: ``BASE_URL + /shop/api/v1/social_links/:id``

* **Method:** `DELETE`

*  **URL Params:** `{ "id": ""}`

* **Success Response:**
 ```json
{
  "id": "",
  "name": "",
  "url": "",
  "created_at": "",
  "updated_at": ""
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Can not delete due to", "status_code": 500 }
         ```