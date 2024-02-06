**User Login and other APIs**
----
### -> User SignUp

* **URL**: ``BASE_URL + /api/v1/signup``

* **Method:** `POST`

* **Form Params:**
  `{ "email(optional)": "abc@def.co",
  "password(required)": "secured_password",
  "password_confirmation(required)": "secured_password",
  "first_name(required)": "first_name",
  "last_name(required)": "last_name"
  "phone(required)": "phone_number" }`

* **Success Response:**
 ```json
{
  "id": 2,
  "first_name": "first name",
  "last_name": "last name",
  "phone": null,
  "email": "abc1@gmail.com",
  "created_at": "2020-12-14T02:21:16.156Z",
  "updated_at": "2020-12-14T02:21:16.156Z",
  "status": "active"
}
```

* **Code:** `201`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Error detail", 500 }
         ```

### -> User SignIn

* **URL**: `BASE_URL + /api/v1/login`

* **Method:** `POST`

*  **URL Params:**
   `{ "email_or_phone": "abc@def.co", "password": "secured_password"}`

* **Success Response:**
 ```json
{
  "token": "secured_token"
}
```
* **Error Response:**
    * **Example - 1 :**
        * **Code:** `406`
        * **Content:**

 ```json
{
  "success": false,
  "status": 406,
  "message": "Staff not found",
  "data": {}
}
```
*
    * **Example-2 :**
        * **Code :** `406`
        * **Content :**
```json
{
  "success": false,
  "status": 406,
  "message": "Invalid",
  "data": {}
}
```

### -> Use User's Secured Token
* **URL**: `BASE_URL + /api/...`

* **Method:** `GET`, `POST`

*  **URL Params:** 
`{...}`
   
* **REQUEST HEADER**

`{"Authorization": "secured_token_from_sign_in"}`

* **Success Response:**
 ```json
{
  "data": "authenticated data"
}
```

* **Code:** `200`, `201`
* **Error Response:**
    * **Code:** `500`, `422`, `400`
    * **Content(example):**
         ```json 
          { "message": "Error detail", 500 }
         ```


### -> User Update

* **URL**: ``BASE_URL + /api/v1/signup``

* **Method:** `PUT`

* **Form Params:**
  `{ "email(required)": "abc@def.co",
  "password(required)": "secured_password",
  "password_confirmation(required)": "secured_password" }`

* **Success Response:**
 ```json
{
  "id": 2,
  "first_name": "first name",
  "last_name": "last name",
  "phone": null,
  "email": "abc1@gmail.com",
  "created_at": "2020-12-14T02:21:16.156Z",
  "updated_at": "2020-12-14T02:21:16.156Z",
  "status": "active"
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Error detail", 500 }
         ```   

### -> User Delete

* **URL**: ``BASE_URL + /api/v1/signup``

* **Method:** `DELETE`

* **Form Params:**
  `{ "email(required)": "abc@def.co",
  "password(required)": "secured_password",
  "password_confirmation(required)": "secured_password",
  "user_name(required)": "name"}`

* **Success Response:**
 ```json
{
  "status": "inactive",
  "id": 3,
  "email": "abc@def.co",
  "user_name": "name",
  "first_name": null,
  "last_name": null,
  "phone": "0111111112",
  "created_at": "2020-12-19T19:10:14.436Z",
  "updated_at": "2020-12-19T19:20:22.593Z"
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Error detail", 500 }
         ```   
