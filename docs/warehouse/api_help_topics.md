### Help topics List
___

* **URL :** `BASE_URL + /api/v1/help_topics`
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
  "success": true,
  "status": 200,
  "message": "Successfully Fetch",
  "data": [
    {
      "id": 65,
      "title": "Account Deactivation & Deletion Information",
      "bn_title": "অ্যাকাউন্ট নিষ্ক্রিয়করণ এবং মুছে ফেলার তথ্য",
      "slug": "account-deactivation-deletion-information",
      "public_visibility": true,
      "article_count": 1,
      "meta_info": null,
      "is_deletable": true,
      "created_by": {
        "id": null,
        "name": null
      }
    },
    {
      "id": 64,
      "title": "afsgdhjk",
      "bn_title": "ert",
      "slug": "afsgdhjk",
      "public_visibility": true,
      "article_count": 1,
      "meta_info": null,
      "is_deletable": true,
      "created_by": {
        "id": null,
        "name": null
      }
    },
    {
      "id": 58,
      "title": "Help Topic Test",
      "bn_title": "সাহায্য বিষয় পরীক্ষা",
      "slug": "help-topic-test",
      "public_visibility": true,
      "article_count": 0,
      "meta_info": {
        "id": 53,
        "meta_title": "Help Topic Test",
        "bn_meta_title": "Help Topic Test",
        "meta_description": "Help Topic Test",
        "bn_meta_description": "Help Topic Test",
        "meta_keyword": [
          "back",
          "test"
        ],
        "bn_meta_keyword": [
          "back",
          "test"
        ],
        "created_by": {
          "id": null,
          "name": null
        }
      },
      "is_deletable": true,
      "created_by": {
        "id": null,
        "name": null
      }
    },
    {
      "id": 48,
      "title": "test help topic",
      "bn_title": "test help topic bn",
      "slug": "test-help-topic-143-hi-bye",
      "public_visibility": true,
      "article_count": 1,
      "meta_info": null,
      "is_deletable": true,
      "created_by": {
        "id": null,
        "name": null
      }
    },
    {
      "id": 9,
      "title": "AboutShopoth",
      "bn_title": "শপথ সম্পর্কে3223",
      "slug": "aboutshopoth",
      "public_visibility": true,
      "article_count": 1,
      "meta_info": null,
      "is_deletable": true,
      "created_by": {
        "id": null,
        "name": null
      }
    },
    {
      "id": 8,
      "title": "About Us",
      "bn_title": "About Us",
      "slug": "about-us2",
      "public_visibility": true,
      "article_count": 1,
      "meta_info": null,
      "is_deletable": true,
      "created_by": {
        "id": null,
        "name": null
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
  "message": "help topics fetch error #{ex.message}",
  "data": {}
}
```
### Help topic details
___

* **URL :** `BASE_URL + /api/v1/help_topics/:id`
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
  "success": true,
  "status": 200,
  "message": "Successfully Fetch",
  "data": {
    "id": 8,
    "title": "About Us",
    "bn_title": "About Us",
    "slug": "about-us2",
    "public_visibility": true,
    "article_count": 1,
    "meta_info": null,
    "is_deletable": true,
    "created_by": {
      "id": null,
      "name": null
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
  "message": "Failed to fetch #{ex.message}",
  "data": {}
}
```
### Help topic update
___

* **URL :** `BASE_URL + /api/v1/help_topics/:id`
* **Method :** `PUT`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "title": "Update Title"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully edited",
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
  "message": "Failed to edit #{ex.message}",
  "data": {}
}
```
### Help topic create
___

* **URL :** `BASE_URL + /api/v1/help_topics/`
* **Method :** `POST`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "title": "Help Topics",
  "bn_title": "সাহায্য বিষয়",
  "slug": "help-topics"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully created",
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
  "message": "Failed to create #{ex.message}",
  "data": {}
}
```
### Help topic delete
___

* **URL :** `BASE_URL + /api/v1/help_topics/:id`
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
  "success": true,
  "status": 200,
  "message": "Successfully deleted",
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
  "message": "Failed to delete #{ex.message}",
  "data": {}
}
```
