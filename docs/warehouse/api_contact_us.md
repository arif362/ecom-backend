### return list of contact us
___

* **URL :** `BASE_URL + /api/v1/contact_us`
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
  "success":true,
  "status":200,
  "message":"Successfully fetched",
  "data":
  [
    {
      "id":133,
      "name":"contact",
      "phone":"0192xxxxxxxx",
      "message":"asda",
      "email":"shopoth_admin@gmail.com",
      "created_at":"2022-04-21T12:24:51.123+06:00"
    }
  ]
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
   "success": false,
   "status": 403,
   "message": "You are not authorized to see",
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
   "message": "failed to fetch",
   "data": {}
}
```
### Contact us details
___

* **URL :** `BASE_URL + /api/v1/contact_us/:id`
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
  "success":true,
  "status":200,
  "message":"Successfully fetched",
  "data":
  {
    "id":121,
    "name":"Maruf",
    "phone":"0192xxxxxx",
    "message":"dasdasd",
    "email":"maruf1609@gmail.com",
    "created_at":"2021-12-02T14:48:32.134+06:00"
  }
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
   "success": false,
   "status": 403,
   "message": "You are not authorized to see",
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
   "message": "failed to fetch",
   "data": {}
}
```
