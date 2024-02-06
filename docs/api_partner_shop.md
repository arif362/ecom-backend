**PartnerShop API's**
----
Create a Partner_Shop

* **URL:** `BASE_URL + /api/v1/partner_shops`

* **Method:** `POST`

*  **URL Params:**
   `{ "sales_representative_id": "1",
   "day": "sat, mon, wed"
   }`

Get all Partner_Shops

* **URL**: `BASE_URL + /api/v1/partner_shops`

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

Update a Partner_Shop

* **URL**: `BASE_URL + /api/v1/partner_shops/:id`

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

Delete a Partner_Shop

* **URL**: `BASE_URL + /api/v1/partner_shops/:id`

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
      