### Send an OTP to given phone number
___

* **URL :** `BASE_URL + /shop/api/v1/otps/send`
* **Method :** `POST`
* **URL Params :**

```json
{
  "phone": "01857123456"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": false,
  "status": 200,
  "message": "Successfully sent OTP.",
  "data": {}
}
```
* **Error Response**
 * **Code :**`404`
 * **Content :**
```json
{
  "success": false,
  "status": 404,
  "message": "User is already verified",
  "data": {}
}
```
* **Error Response**
 * **Code :**`404`
 * **Content :**
```json
{
  "success": false,
  "status": 404,
  "message": "User does not exist",
  "data": {}
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "OTP sent failed. Please try again!",
   "data": {}
}
```
### Verify an otp
___

* **URL :** `BASE_URL + /shop/api/v1/otps/verify`
* **Method :** `POST`
* **URL Params :**

```json
{
  "phone": "01857123456",
  "otp": "23445"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": false,
  "status": 200,
  "message": "Successfully verified",
  "data": {}
}
```
* **Error Response**
 * **Code :**`404`
 * **Content :**
```json
{
  "success": false,
  "status": 404,
  "message": "Wrong OTP provided.",
  "data": {}
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "OTP verification failed",
   "data": {}
}
```
### Send an OTP to change user phone number
___

* **URL :** `BASE_URL + /shop/api/v1/otps/phone_change_request`
* **Method :** `PUT`
* **URL Params :**

```json
{
  "phone": "01857123456"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": false,
  "status": 200,
  "message": "Successfully sent OTP.",
  "data": {}
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "OTP sent failed. Please try again!",
   "data": {}
}
```
### Verify an otp to change user phone number.
___

* **URL :** `BASE_URL + /shop/api/v1/otps/phone_change_verify`
* **Method :** `PUT`
* **URL Params :**

```json
{
  "phone": "01857123456",
  "otp": "23445"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": false,
  "status": 200,
  "message": "Successfully changed user phone number.",
  "data": {}
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to change user phone number, please try again.",
   "data": {}
}
```
