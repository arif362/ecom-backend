**Address API's**
----
***Create a address :*** First we need to create district, thana and area to create an address.
Because we need those model's id in address model.


* **URL:** `BASE_URL + /api/v1/addresses`

* **Method:** `POST`

*  **URL Params:**
   `{ "address[district_id]": "1",
   "address[thana_id]": "1",
   "address[area_id]": "1",
   "address[address_line]": "Kota, Cholisia, Abhaynagar, Jessore.",
   "address[bn_address_line]": "Kota, Cholisia, Abhaynagar, Jessore.",
   "address[user_id](optional)": "1",
   "address[default_address](optional)": "True"/"true",
   "address[zip_code](optional)": "1206"
   "address[bn_zip_code](optional)": "1206"
   "address[phone](optional)": "0123456789"
   "address[bn_phone](optional)": "0123456789"
   }`

Get all addresses

* **URL**: `BASE_URL + /api/v1/addresses`

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
    
Update a address

* **URL**: `BASE_URL + /api/v1/addresses/:id`

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

Delete a address

* **URL**: `BASE_URL + /api/v1/addresses/:id`

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
