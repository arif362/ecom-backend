### Otp Generate
___

* **URL :** `BASE_URL + partner/api/v1/secret`

* **Method :** `POST`

* **URL Params :**

```json
{
  "phone": "017xxxxxxxx"
}
```
* **Success Response**
* **Code :**`201`
* **Content :**
```json
{
  "message": "#{auth_token}",
  "status_code": 201
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "error": "#{otp.error}"
}
```
### Change partner's password
___

* **URL :** `BASE_URL + partner/api/v1/secret`

* **Method :** `PUT`

* **URL Params :**

```json
{
  "otp": "2342",
  "token": "auth_token"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": "Successfully changed password.",
  "status_code": 200
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "error": "OTP does not match!"
}
```
