**Staff API (Warehouse)**
----
First we need to make sure that there are valid `staff_role` and `warehouse` in the system to be
assigned in the staff.

Create a Staff

* **URL**: ``BASE_URL + api/v1/staffs``

* **Method:** `POST`

*  **URL Params:**
   `{
   "first_name": "Abdur",
   "last_name": "Rahim",
   "email": "ar23@gmail.com",
   "password": "123sdn",
   "warehouse_id": 1,
   "staff_role_id": 1,
   "address_line": "kota, chalisia, Dhaka"
   }`

* **Success Response:**
 ```json
{
  "id": 3,
  "first_name": "Abdur",
  "last_name": "Rahim",
  "email": "ar23@gmail.com",
  "staff_role_id": 1,
  "password_hash": "$2a$12$t3fa9pDV6cmN6qDgGcXzq.HjrJI9u9u9h43eZQQj/A6fVyNIpB46W",
  "warehouse_id": 1,
  "created_at": "2020-12-19T09:11:29.679Z",
  "updated_at": "2020-12-19T09:11:29.679Z",
  "address_line": "kota, chalisia, Dhaka"
}
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          {  "message": "Unable to create Staff due to *** " }
         ```
  `Here *** means the cause, for which error happened.`


Get all Staffs

* **URL**: ``BASE_URL + api/v1/staffs``

* **Method:** `GET`

*  **URL Params:** 
    `None`

* **Success Response:**
 ```json
[
  {
    "id": 1,
    "first_name": "Abdur",
    "last_name": "Rahim",
    "email": "ar21@gmail.com",
    "staff_role_id": 1,
    "warehouse_id": 1,
    "created_at": "2020-12-19T09:11:00.879Z",
    "updated_at": "2020-12-19T09:11:00.879Z",
    "address_line": "kota, chalisia, Dhaka",
    "permissions": []
  },
  {
    "id": 2,
    "first_name": "Abdur",
    "last_name": "Rahim",
    "email": "ar@gmail.com",
    "staff_role_id": 1,
    "warehouse_id": 1,
    "created_at": "2020-12-19T09:11:09.703Z",
    "updated_at": "2020-12-19T09:11:09.703Z",
    "address_line": "kota, chalisia, Dhaka",
    "permissions": []
  },
  {
    "id": 3,
    "first_name": "Abdur",
    "last_name": "Rahim",
    "email": "ar23@gmail.com",
    "staff_role_id": 1,
    "warehouse_id": 1,
    "created_at": "2020-12-19T09:23:56.573Z",
    "updated_at": "2020-12-19T09:23:56.573Z",
    "address_line": "kota, chalisia, Dhaka",
    "permissions": []
  }
]
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          {  "message": "Unable to update Staff due to *** " }
         ```
    `Here *** means the cause, for which error happened.`

Update a Staff

* **URL**: ``BASE_URL + api/v1/staffs/:id``

* **Method:** `PUT`

*  **URL Params:**
   `{
   "first_name": "Abdur",
   "last_name": "Rahim",
   "email": "ar2@gmail.com",
   "password": "123sdn",
   "warehouse_id": 1,
   "staff_role_id": 1,
   "address_line": "kota, chalisia, Dhaka"
   }`

* **Success Response:**
 ```json
{
  "id": 3,
  "first_name": "Abdur",
  "last_name": "Rahim",
  "email": "ar2@gmail.com",
  "warehouse_id": 1,
  "staff_role_id": 1,
  "address_line": "kota, chalisia, Dhaka",
  "created_at": "2020-12-19T09:11:29.679Z",
  "updated_at": "2020-12-19T09:11:58.668Z",
  "permissions": []
}
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          {  "message": "Unable to update Staff due to *** " }
         ```
  `Here *** means the cause, for which error happened.`

Delete a Staff

* **URL**: ``BASE_URL + api/v1/staffs/:id``

* **Method:** `DELETE`

*  **URL Params:**
   `None`

* **Success Response:**
 ```json
"Successfully Deleted"
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          {  "message": "Unable to delete Staff with id * due to *** " }
         ```
      `Here * means the id of that staff and *** means the cause, for which error happened.`

