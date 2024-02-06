### NewsLetters list
___

* **URL :** `BASE_URL + /api/v1/news_letters`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id": 91,
    "email": "debashish.halder@misfit.tech",
    "is_active": true
  },
  {
    "id": 94,
    "email": "shopoth@central.com",
    "is_active": true
  }
]
```
### NewsLetters Details
___

* **URL :** `BASE_URL + /api/v1/news_letters/:id`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "id": 91,
  "email": "debashish.halder@misfit.tech",
  "is_active": true
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "status_code": 404,
  "message": "Unable to find newsLetter."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Unable to show details of newsLetter."
}
```
### NewsLetters Details
___

* **URL :** `BASE_URL + /api/v1/news_letters`
* **Method :** `POST`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "email": "newsletter@shopth.com"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "status_code": 200,
  "message": "Successfully joined to newsLetter."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Unable to create newsLetter."
}
```
### NewsLetters Update
___

* **URL :** `BASE_URL + /api/v1/news_letters/:id`
* **Method :** `PUT`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "email": "newsletter2@shopth.com"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "status_code": 200,
  "message": "Successfully updated newsLetter's information."
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "status_code": 404,
  "message": "Unable to find newsLetter."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Unable to updated newsLetter's information."
}
```
### NewsLetters Delete
___

* **URL :** `BASE_URL + /api/v1/news_letters/:id`
* **Method :** `DELETE`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "status_code": 200,
  "message": "Successfully deleted newsLetter."
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "status_code": 404,
  "message": "Unable to find newsLetter."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Unable to delete newsLetter."
}
```
