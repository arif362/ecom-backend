### User Modify Reasons List
___
* **URL :** `BASE_URL + /api/v1/modify_reasons`
* **Method :** `GET`
* **URL Params :**
```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched reason list",
  "data": [
    {
      "id": 1,
      "title": "Unnecessary Account",
      "title_bn": "Bn unnecessary account"
    },
    {
      "id": 2,
      "title": "Reason 1",
      "title_bn": "Reason bn 1"
    }
  ]
}

```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Failed to fetch",
   "data": {}
}
```
### User Modify Reason Details
___
* **URL :** `BASE_URL + /api/v1/modify_reasons/:id`
* **Method :** `GET`
* **URL Params :**
```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully fetched reason details",
  "data": {
    "id": 1,
    "title": "Reason 1",
    "title_bn": "কারণ 1"
  }
}

```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch reason details",
   "data": {}
}
```
### Create User Modify Reason
___
* **URL :** `BASE_URL + /api/v1/modify_reasons/`
* **Method :** `POST`
* **URL Params :**
```json
{
    "title": "Reason 1",
    "title_bn": "কারণ 1"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully created reason",
  "data": {
    "id": 1,
    "title": "Reason 1",
    "title_bn": "কারণ 1"
  }
}

```
* **Error Response**
* **Example - 1:**
  * **Code :**`406`
  * **Content :**
```json
{
   "success": false,
   "status": 406,
   "message": "Reason already exist",
   "data": {}
}
```
* **Error Response**
* **Example - 2:**
  * **Code :**`422`
  * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to create reason",
   "data": {}
}
```
### Update User Modify Reason
___
* **URL :** `BASE_URL + /api/v1/modify_reasons/:id`
* **Method :** `PUT`
* **URL Params :**
```json
{
    "id": 1,
    "title": "Reason 1",
    "title_bn": "কারণ 1"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully updated reason",
  "data": {
    "id": 1,
    "title": "Reason 1",
    "title_bn": "কারণ 1"
  }
}

```
* **Error Response**
* **Example - 1:**
  * **Code :**`406`
  * **Content :**
```json
{
   "success": false,
   "status": 404,
   "message": "Reason not found",
   "data": {}
}
```
* **Error Response**
* **Example - 2:**
  * **Code :**`422`
  * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to update reason",
   "data": {}
}
```
### Delete User Modify Reason
___
* **URL :** `BASE_URL + /api/v1/modify_reasons/:id`
* **Method :** `DELETE`
* **URL Params :**
```json
{
    "id": 1
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully deleted",
  "data": {}
}

```
* **Error Response**
* **Example - 1:**
  * **Code :**`406`
  * **Content :**
```json
{
   "success": false,
   "status": 404,
   "message": "Reason not found",
   "data": {}
}
```
* **Error Response**
* **Example - 2:**
  * **Code :**`422`
  * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to update reason",
   "data": {}
}
```


