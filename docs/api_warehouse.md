**Warehouse APIs**
----

##### Create a Distribution warehouse

* **URL**: ``BASE_URL + /api/v1/warehouses``

* **Method:** `POST`

* **URL Params:**
  `{
  "warehouse":{
  "name" : "Khulna",
  "bn_name": "ft",
  "email" : "salahuddin24@gmail.com",
  "password" : "Dhaka",
  "phone": "01967823678",
  "address" : {
  "addrees_line" : "Abc",
  "bn_addrees_line" : "Bn Abc",
  "disctrict_id" : 1,
  "thana_id" : 3,
  "area_id" : 5
  }
  }  
  }`

`Here name, bn_name and email need to be unique. To crate a warehouse we must give
name, bn_name, address, email, warehouse_type and password as a parameter. we can
give warehouse_type 'distribution' or it will automatically create 'distribution'
type warehouse. phone is optional. You can give it as a parameter or warehouse will
be created with phone as null value. The address fields for warehouse is optional.
Once the address is provided, then the requires fields for the address should be
provided.`

* **Success Response:**

 ```json
 {
  "name": "Khulna",
  "bn_name": "ft",
  "email": "salahuddin24@gmail.com",
  "phone": "01967823678",
  "address": {
    "addrees_line": "Abc",
    "bn_addrees_line": "Bn Abc",
    "disctrict_id": 1,
    "thana_id": 3,
    "area_id": 5
  }
}
```

* **Error Response:**
    * **Content:**
         ```json
          { "message": "Validation failed: ***", "status_code": 422 }
         ```

`Here *** means the cause for which the validation failed`

##### Create a Central warehouse

`We need to give "warehouse_type": "central" in order to create a central warehouse.`

* **URL**: ``BASE_URL + /api/v1/warehouses``

* **Method:** `POST`

* **URL Params:**
  `{
  "warehouse":{
  "name": "Khulna-jessore",
  "bn_name": "ftt",
  "email": "salahuddin294@gmail.com",
  "phone": "01967823678",
  "warehouse_type": "central",
  "password" : "Dhaka",
  "address" : {
  "addrees_line" : "Abc",
  "bn_addrees_line" : "Bn Abc",
  "disctrict_id" : 1,
  "thana_id" : 3,
  "area_id" : 5
  }
  }  
  }
  `

`Here name, bn_name and email need to be unique. To crate a warehouse we must give
name, bn_name, address, email, warehouse_type and password as a parameter. warehouse_type
need to give 'central'. phone is optional. You can give it as a parameter
or warehouse will be created with phone as null value.`

* **Success Response:**

 ```json
 {
  "name": "Khulna-jessore",
  "bn_name": "ftt",
  "email": "salahuddin294@gmail.com",
  "phone": "01967823678",
  "address": {
    "addrees_line": "Abc",
    "bn_addrees_line": "Bn Abc",
    "disctrict_id": 1,
    "thana_id": 3,
    "area_id": 5
  }
}
```

* **Error Response:**
* **Content:**
  ```json
  { "message": "Validation failed: ***", "status_code": 422 }
  ```

##### Get all warehouses

* **URL**: ``BASE_URL + /api/v1/warehouses``

* **Method:** `GET`

* **URL Params:** `None`

* **Success Response:**

 ```json
 [
  {
    "name": "Jessore",
    "bn_name": "Jessore",
    "email": "salahuddin02@gmail.com",
    "phone": "01967823678",
    "address": {}
  },
  {
    "name": "Khulna",
    "bn_name": "f",
    "email": "salahuddin24@gmail.com",
    "phone": "01967823678",
    "address": {}
  },
  {
    "name": "Khulna-jessore",
    "bn_name": "ftt",
    "email": "salahuddin294@gmail.com",
    "phone": "01967823678",
    "address": {}
  }
]
```

##### Update a warehouse

* **URL**: ``BASE_URL + /api/v1/warehouses/:id``

* **Method:** `PUT`

* **URL Params:**
  `{
  "warehouse":{
  "name" : "Khulna",
  "bn_name": "ft",
  "email" : "salahuddin245@gmail.com",
  "warehouse_type": "distribution",
  "password" : "Dhaka",
  "phone": "01967823678",
  "address": {
  "addrees_line" : "Cdf",
  "bn_addrees_line" : "Bn Cdf",
  "disctrict_id" : 4,
  "thana_id" : 7,
  "area_id" : 9
  }
  }  
  }
  `
* **Success Response:**

 ```json
 {
  "name": "Khulna",
  "bn_name": "ft",
  "email": "salahuddin245@gmail.com",
  "warehouse_type": "distribution",
  "phone": "01967823678",
  "address": {
    "addrees_line": "Cdf",
    "bn_addrees_line": "Bn Cdf",
    "disctrict_id": 4,
    "thana_id": 7,
    "area_id": 9
  }
}
```

* **Error Response:**
* **Content:**
  ```json
  { "message": "Validation failed: ***", "status_code": 422 }
  ```

##### Delete a warehouse

* **URL**: ``BASE_URL + /api/v1/warehouses/:id``

* **Method:** `DELETE`

* **URL Params:**
  `None`
* **Success Response:**

```json
{
  "message": "Successfully deleted Warehouse with id #{params[:id]}",
  "status_code": 200
}
```

`Here #{params[:id]} will return the id of deleted warehouse.`

* **Error Response:**
* **Content:**
  ```json
  { "message": "Validation failed: ***", "status_code": 422 }
  ```

##### Get distributor balances:

* **URL**: ``BASE_URL + /api/v1/warehouses/distributors``

* **Method:** `GET`

* **URL Params:**

```json
{
  "title": "test (optional)",
  "start_date_time": "2022-05-12(optional)",
  "end_date_time": "2022-05-12(optional)",
  "skip_pagination": "false(optional)"
}
```

* **Success Response:**

```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched distributor balances.",
  "data": [
    {
      "name": "test distributor",
      "bn_name": "bn test distributor",
      "phone": "",
      "email": "",
      "distributor_collected": "1801.0",
      "distributor_collectable": "1801.0",
      "total_return_collected": 0,
      "total_return_collectable": 1
    }
  ]
}
```

* **Error Response:**
* **Content:**
* **Status**: 200

```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched distributor balances.",
  "data": []
}
```
