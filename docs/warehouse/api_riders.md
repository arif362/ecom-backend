**Riders API's**
----
#### Update a rider

* **URL**: ``BASE_URL + /api/v1/riders``

* **Method:** `PUT`

    * **URL Params:**
      `{"rider": {
      "name": "Ajijul Kazi",
      "phone": "01725570361",
      "password_hash": 'password',
      "email": "example@gmail.com"
      "distributor_id": 26
      }}`


* **Success Response:**
* **Code:** `200`
 ```json
 {
  "id": 1,
  "name": "Sumon Rider",
  "phone": "01727212136",
  "email": "example2@gmail.com",
  "warehouse_id": 2,
  "distributor_id": 26,
  "cash_collected": "0.0",
  "total_order": 0
}
```

* **Code:** `200`
  * **Error Response:**
      * **Code:** `422`
      * **Content:**
           ```json 
            { "message": "", "status_code":  }
           ```
    * **Like:**

    ```json 
        { 
          "message": "Phone number is already been taken.",
         "status_code": 406 }
      ```
### Get all riders
___

* **URL :** `BASE_URL + /api/v1/riders`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "distributor_id=": 10
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id":174,
    "name":"HeroHondaRider",
    "phone":"0170xxxxxxxx",
    "email":"h@gmail.com",
    "warehouse_id":8,
    "distributor_id":10,
    "distributor_name":"Virtual Distributor",
    "cash_collected":"0.0",
    "total_order":4,
    "created_by":
    {
      "id":null,
      "name":null
    }
  },
  {
    "id":173,
    "name":"RA",
    "phone":"017xxxxxx",
    "email":null,
    "warehouse_id":8,
    "distributor_id":10,
    "distributor_name":"Virtual Distributor",
    "cash_collected":"0.0",
    "total_order":7,
    "created_by":
    {
      "id":null,
      "name":null
    }
  }
]
```
