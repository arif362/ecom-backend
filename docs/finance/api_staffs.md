### Log in to finance staff.
___
* **URL :** `BASE_URL + finance/api/v1/login`
* **Method :** `POST`
* **URL Params :**

```json
{
  "email": "shopoth@central.com",
  "password": "123456"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": {
    "token": "auth_token",
    "user_name": "finanace admin"
  },
  "status_code": 200
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": {
    "error": "invalid"
  },
  "status_code": 422
}
```


