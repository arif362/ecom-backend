### ADD SOCIAL MEDIA
___

* **URL :** `BASE_URL + /shop/api/v1/social_links`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "name": "Shopoth",
  "url": "www.shopoth.com"
}
```
* **Success Response**
 * **Code :**`201`
 * **Content :**
```json
{
  "id": 1,
  "name": "Shopoth",
  "url": "www.shopoth.com",
  "created_at": "2022-12-21T18:57:07.707+06:00",
  "updated_at": "2022-12-21T18:57:07.707+06:00",
  "created_by_id": null
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
### SOCIAL MEDIA Details
___

* **URL :** `BASE_URL + /shop/api/v1/social_links/:id/show`
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
  "name": "Shopoth",
  "url": "www.shopoth.com",
  "created_at": "2022-12-21T18:57:07.707+06:00",
  "updated_at": "2022-12-21T18:57:07.707+06:00",
  "created_by_id": null
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
### SOCIAL MEDIA Update
___

* **URL :** `BASE_URL + /shop/api/v1/social_links/:id/update`
* **Method :** `PUT`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "name": "Shopoth Agami"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "id": 1,
  "name": "Shopoth Agami",
  "url": "www.shopoth.com",
  "created_at": "2022-12-21T18:57:07.707+06:00",
  "updated_at": "2022-12-21T18:57:07.707+06:00",
  "created_by_id": null
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
### SOCIAL MEDIA delete
___

* **URL :** `BASE_URL + /shop/api/v1/social_links/:id`
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
  "name": "Shopoth Agami",
  "url": "www.shopoth.com",
  "created_at": "2022-12-21T18:57:07.707+06:00",
  "updated_at": "2022-12-21T18:57:07.707+06:00",
  "created_by_id": null
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
