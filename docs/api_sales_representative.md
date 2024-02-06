**SalesRepresentative API's**
----
Create a Sales_Representative

* **URL:** `BASE_URL + /api/v1/sales_representatives`

* **Method:** `POST`

*  **URL Params:**
   `{ "warehouse_id": "1",
   "name": "Josim",
   "area": "Jessore"
   }`

Get all Sales_Representatives

* **URL**: `BASE_URL + /api/v1/sales_representatives`

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

Update a Sales_Representative

* **URL**: `BASE_URL + /api/v1/sales_representatives/:id`

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

Delete a Sales_Representative

* **URL**: `BASE_URL + /api/v1/sales_representatives/:id`

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
      