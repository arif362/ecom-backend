### Customer Care Agent Login
___

* **URL :** `BASE_URL + /customer_care/api/v1/login`

* **Method :** `POST`

* **URL Params :**

```json
{
    "email": "staff1@careagent.com",
    "password": "123456"
}
```
* **Success Response**
  * **Code :**`200`
  * **Content :**
```json
{
    "success": true,
    "status": 200,
    "message": "Successfully logged in.",
    "data": {
        "token": "eyJhbGciOiJIUzI1NiJ9.I"
    }
}
```
* **Error Response**
  * **Code :**`406`
  * **Content :**
```json
{
   "success": false,
   "status": 406,
   "message": "Not found",
   "data": {}
}
```

