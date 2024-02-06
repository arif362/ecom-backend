### Article list
___

* **URL :** `BASE_URL + /api/v1/articles`
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
  "message":"Successfully Fetch",
  "data":[
    {
      "id":37,
      "title":"Account Deactivation Note",
      "slug":"account-deactivation-note",
      "footer_visibility":false,
      "position":-1,
      "bn_title":"abc",
      "body":"\u003cp\u003eHow can I deactivate or delete my account? If you'd like to deactivate or delete your shopoth account, simply fill up the account deactivation and deletion form and refer to the steps below:  1. Initiate your request by filling out the form 2. You'll receive a call within 72 hours for verification 3. Your account will be deactivated or deleted as requested\u003c/p\u003e","bn_body":"\u003cp\u003eabc\u003c/p\u003e","public_visibility":true,"help_topic_id":65,"help_topic_name":"Account Deactivation \u0026 Deletion Information","meta_info":null,"is_deletable":false,"created_by":{"id":null,"name":null}},{"id":31,"title":"dfg","slug":"dfg","footer_visibility":false,"position":0,"bn_title":"sdfv",
      "body":"\u003cp\u003edfgn\u003c/p\u003e",
      "bn_body":"\u003cp\u003edfgn\u003c/p\u003e",
      "public_visibility":true,
      "help_topic_id":64,
      "help_topic_name":"afsgdhjk",
      "meta_info":null,
      "is_deletable":true,
      "created_by":{
        "id":null,
        "name":null
      }
    },
    {
      "id":19,
      "title":"About Us",
      "slug":"about-us-143-hi",
      "footer_visibility":true,
      "position":5,
      "bn_title":"About Us",
      "body":"\u003cp\u003eAbout Us body hello hello\u0026nbsp;\u003c/p\u003e",
      "bn_body":"\u003cp\u003eAbout Us body\u003c/p\u003e",
      "public_visibility":true,
      "help_topic_id":48,
      "help_topic_name":"test help topic",
      "meta_info":null,
      "is_deletable":true,
      "created_by":
      {
        "id":null,
        "name":null
      }
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
   "message": "Unable to fetch areas.",
   "data": {}
}
```
### Article Details
___

* **URL :** `BASE_URL + /api/v1/articles/:id`
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
  "message":"Successfully Fetch",
  "data":{
    "id":19,
    "title":"About Us",
    "slug":"about-us-143-hi",
    "footer_visibility":true,
    "position":5,
    "bn_title":"About Us",
    "body":"\u003cp\u003eAbout Us body hello hello\u0026nbsp;\u003c/p\u003e",
    "bn_body":"\u003cp\u003eAbout Us body\u003c/p\u003e",
    "public_visibility":true,
    "help_topic_id":48,
    "help_topic_name":"test help topic",
    "meta_info":null,
    "is_deletable":true,
    "created_by":
    {
      "id":null,
      "name":null
    }
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
   "message": "Unable to fetch areas.",
   "data": {}
}
```
### Article Create
___

* **URL :** `BASE_URL + /api/v1/articles`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "position": 1,
  "footer_visibility": false,
  "public_visibility": true,
  "help_topic_id": 9,
  "bn_body": "<p>Article Body</p>",
  "body": "<p>Article Body</p>",
  "bn_title": "Shopoth Article",
  "slug": "shopoth-article",
  "title": "Shopoth Article",
  "meta_datum_attributes": {}
}
```
* **Success Response**
* **Code :**`201`
* **Content :**
```json
{
  "success":true,
  "status":201,
  "message":"Successfully created",
  "data":{}
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Failed to create #{error.message}",
   "data": {}
}
```
### Article Delete
___

* **URL :** `BASE_URL + /api/v1/articles/:id`
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
  "success":true,
  "status":200,
  "message":"Successfully deleted",
  "data":{}
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Failed to delete #{error.message}",
   "data": {}
}
```
### Article Update
___

* **URL :** `BASE_URL + /api/v1/articles/:id`
* **Method :** `PUT`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "position": 1,
  "footer_visibility": false,
  "public_visibility": true,
  "help_topic_id": 9,
  "bn_body": "<p>Article Body</p>",
  "body": "<p>Article Body</p>",
  "bn_title": "Shopoth Article",
  "slug": "shopoth-article",
  "title": "Shopoth Article",
  "meta_datum_attributes": {}
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully updated",
  "data":{}
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Failed to update #{error.message}",
   "data": {}
}
```
