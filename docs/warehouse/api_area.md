**Area API's**
----
Create a area

* **URL:** `BASE_URL + /api/v1/areas`

* **Method:** `POST`

*  **URL Params:**
   `{ "thana_id": "1"
   "name": "Noapara",
   "bn_name": "Noapara"
   }`

Get all areas

* **URL**: `BASE_URL + /api/v1/areas`

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

Update a area

* **URL**: `BASE_URL + /api/v1/areas/:id`

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

Delete a area

* **URL**: `BASE_URL + /api/v1/areas/:id`

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
### App version update.
___

* **URL :** `BASE_URL + /api/v1/areas/search`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "thana_id": 4
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched areas.",
  "data": [
    {
      "id": 14,
      "thana_id": 4,
      "name": "Bogra",
      "bn_name": "Local Brand",
      "home_delivery": true
    }
  ]
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch areas.",
   "data": {}
}
```
