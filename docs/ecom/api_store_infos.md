### Create Store Info
___

* **URL :** `BASE_URL + /shop/api/v1/store_infos`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "official_email": "store@shopoth.com",
  "contact_address": "contact_address",
  "contact_number": "0176123456"
}
```
* **Success Response**
 * **Code :**`201`
 * **Content :**
```json
{
  "id": 1,
  "official_email": "store@shopoth.com",
  "contact_address": "contact_address",
  "contact_number": 176123456,
  "footer_bottom": null,
  "created_at": "2022-12-21T19:20:47.664+06:00",
  "updated_at": "2022-12-21T19:20:47.664+06:00"
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Can not create due to #{ex.message}",
   "data": {}
}
```
### Store Info Details
___

* **URL :** `BASE_URL + /shop/api/v1/store_infos/:id/show`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "id": 1,
  "official_email": "store@shopoth.com",
  "contact_address": "contact_address",
  "contact_number": 176123456,
  "footer_bottom": null,
  "created_at": "2022-12-21T19:20:47.664+06:00",
  "updated_at": "2022-12-21T19:20:47.664+06:00"
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Can not show due to #{ex.message}",
   "data": {}
}
```
### Store Info Update
___

* **URL :** `BASE_URL + /shop/api/v1/store_infos/:id/update`
* **Method :** `PUT`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "official_email": "store_update@shopoth.com"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "id": 1,
  "official_email": "store_update@shopoth.com",
  "contact_address": "contact_address",
  "contact_number": 176123456,
  "footer_bottom": null,
  "created_at": "2022-12-21T19:20:47.664+06:00",
  "updated_at": "2022-12-21T19:20:47.664+06:00"
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Can not update due to #{ex.message}",
   "data": {}
}
```
### Store Info Delete
___

* **URL :** `BASE_URL + /shop/api/v1/store_infos/:id`
* **Method :** `DELETE`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "id": 1,
  "official_email": "store@shopoth.com",
  "contact_address": "contact_address",
  "contact_number": 176123456,
  "footer_bottom": null,
  "created_at": "2022-12-21T19:20:47.664+06:00",
  "updated_at": "2022-12-21T19:20:47.664+06:00"
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Can not delete due to #{ex.message}",
   "data": {}
}
```
