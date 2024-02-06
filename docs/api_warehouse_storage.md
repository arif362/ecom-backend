**WarehouseStorage API's**
----
Create a Warehouse_Storage

* **URL:** `BASE_URL + /api/v1/warehouse_storages`

* **Method:** `POST`

*  **URL Params:**
   `{ "warehouse_id": "1",
   "name": "Jessore_wh_storage",
   "bn_name": "Jessore_wh_storage",
   "area": "Jessore",
   "location": "Jessore"
   }`

Get all Warehouse_Storage

* **URL**: `BASE_URL + /api/v1/warehouse_storages`

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

Update a Warehouse_Storage

* **URL**: `BASE_URL + /api/v1/warehouse_storages/:id`

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

Delete a Warehouse_Storage

* **URL**: `BASE_URL + /api/v1/warehouse_storages/:id`

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
      