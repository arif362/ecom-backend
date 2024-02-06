**Thana API's**
----
Create a thana

* **URL:** `BASE_URL + /api/v1/thanas`

* **Method:** `POST`

*  **URL Params:**
   `{ "district_id": "1"
   "name": "Abhaynagar",
   "bn_name": "Abhaynagar"
   }`

Get all thanas

* **URL**: `BASE_URL + /api/v1/thanas`

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```

Update a thana

* **URL**: `BASE_URL + /api/v1/thanas/:id`

* **Method:** `PUT`

*  **URL Params:** `None`

* **Success Response:**
 ```json
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```

Delete a thana

* **URL**: `BASE_URL + /api/v1/thanas/:id`

* **Method:** `DELETE`

*  **URL Params:** `None`

* **Success Response:**
 ```json 
 Successfully deleted.
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```
      