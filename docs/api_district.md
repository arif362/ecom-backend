**District API's**
----
Create a district 

* **URL:** `BASE_URL + /api/v1/districts`

* **Method:** `POST`

*  **URL Params:**
   `{ "name": "Jessore",
   "bn_name": "Jessore"
   }`

Get all districts

* **URL**: `BASE_URL + /api/v1/districts`

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

Update a district

* **URL**: `BASE_URL + /api/v1/districts/:id`

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

Delete a district

* **URL**: `BASE_URL + /api/v1/districts/:id`

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
      