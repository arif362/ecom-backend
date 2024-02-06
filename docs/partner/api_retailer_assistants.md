### Forget password
___

* **URL :** `BASE_URL + partner/api/v1/retailer_assistants/secret`

* **Method :** `PUT`

* **URL Params :**

```json
{
  "phone": "017xxxxxxxx"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status_code": 200, 
  "message": "Successfully otp sent"
}

```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": true,
  "status_code": 404,
  "message": "RA does not exist with this phone number"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Unable to send otp"
}
```
### Password reset
___

* **URL :** `BASE_URL + partner/api/v1/retailer_assistants/reset_password`

* **Method :** `PUT`

* **URL Params :**

```json
{
  "phone": "017xxxxxxxx",
  "otp": "1232",
  "password": "xxxxxx",
  "password_confirmation": "xxxxxxx"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status_code": 200,
  "message": "Successfully reset"
}

```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": true,
  "status_code": 404,
  "message": "Wrong number or otp provided"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Unable to update, reason: #{error.message}"
}
```
