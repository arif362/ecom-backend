### Customer Details
___

* **URL :** `BASE_URL + partner/api/v1/customer/:id/details`

* **Method :** `GET`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "name": "Shopoth User",
  "phone": "0185xxxxxxx",
  "email": "shopoth_user@gmail.com"
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to find customer",
  "status_code": 404
}
```
### Customer Confirmation from Partner App
___

* **URL :** `BASE_URL + partner/api/v1/customer/confirm`

* **Method :** `POST`

* **URL Params :**

```json
{
    "first_name": "Shopoth",
    "last_name": " User",
    "phone": "0176xxxxxx"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "token": "Auth_token",
  "customer_id": {
    "id": 729,
    "otp": "88942",
    "email": null,
    "phone": "0176xxxxxx",
    "age": null,
    "full_name": "Shopoth User",
    "is_deleted": false,
    "whatsapp": null,
    "viber": null,
    "imo": null,
    "nid": null,
    "home_address": null,
    "status": "active",
    "first_name": "Shopoth",
    "last_name": " User",
    "created_at": "2022-12-26T12:54:40.986+06:00",
    "updated_at": "2022-12-26T12:54:41.365+06:00",
    "is_loyal": false,
    "gender": null,
    "registerable_type": "Partner",
    "registerable_id": 151,
    "user_type": "shopoth",
    "date_of_birth": null,
    "temporary_otp": null,
    "temporary_phone": null,
    "category": "general",
    "verifiable_type": null,
    "verifiable_id": null,
    "verified_at": null,
    "is_app_download": null,
    "has_smart_phone": null,
    "partner_id": null,
    "is_otp_verified": false
  },
  "message": "New customer created and otp sent."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to verify customer",
  "status_code": 422
}
```
###  Resend OTP by partner
___

* **URL :** `BASE_URL + partner/api/v1/customer/resend_otp`

* **Method :** `POST`

* **URL Params :**

```json
{
  "phone": "0176xxxxxx"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "token": "#{otp.token}",
  "customer_id": "#{customer_id}",
  "message": "otp sent"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Too many OTP sent. Please try again after 1 hour",
  "status_code": 422
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "OTP error: #{otp.error}",
  "status_code": 422
}
```

### Verify token
___

* **URL :** `BASE_URL + partner/api/v1/customer/verify_token`

* **Method :** `POST`

* **URL Params :**

```json
{
  "phone": "0176xxxxxxx",
  "otp": " 88942",
  "token": "Auth_token"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": "OTP verified.",
  "customer_id": 729
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to verify otp",
  "status_code": 422
}
```
### Customer Create by Retailer Assistant
___

* **URL :** `BASE_URL + partner/api/v1/customer/confirm`

* **Method :** `POST`

* **URL Params :**

```json
{
  "first_name": "Shopoth",
  "last_name": " User",
  "phone": "0176xxxxxxx",
  "partner_id": 157,
  "gender": "female",
  "age": 45
}
```
* **Success Response**
* **Code :**`201`
* **Content :**
```json
{
  "success": true,
  "message": "successfully created",
  "status_code": 201
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "success": false,
  "message": "#{error}",
  "status_code": 422
}
```
###  Verify otp by Retailer Assistant
___

* **URL :** `BASE_URL + partner/api/v1/customer/otp_resend`

* **Method :** `POST`

* **URL Params :**

```json
{
  "phone": "0176xxxxxx"
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
  "success": false,
  "message": "OTP does not match",
  "status_code": 404
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "success": false,
  "message": "#{error}",
  "status_code": 422
}
```
