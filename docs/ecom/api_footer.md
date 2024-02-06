**Footer API's**
----

Get all information of footer

* **URL**: ``BASE_URL + /shop/api/v1/footer``

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
{
  "contact_address": {
    "id": null,
    "official_email": "",
    "contact_address": "",
    "contact_number": ""
  },
  "important_link": [
    {
      "title": "",
      "view_url": ""
    },
    {
      "title": "",
      "view_url": ""
    }
  ],
  "social_link": [
    {
      "id": "",
      "name": "",
      "url": ""
    },
    {
      "id": "",
      "name": "",
      "url": ""
    }
  ]
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Something went wrong", "status_code": 500 }
         ```

### Article list with footer visibility
___

* **URL :** `BASE_URL + /shop/api/v1/footer/articles`
* **Method :** `POST`
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
      "id": 19,
      "title": "About Us",
      "slug": "about-us-143-hi",
      "bn_title": "About Us",
      "body": "<p>About Us body hello hello&nbsp;</p>",
      "bn_body": "<p>About Us body</p>",
      "position": 5,
      "help_topic_id": 48,
      "help_topic_name": "test help topic",
      "help_topic_slug": "test-help-topic-143-hi-bye"
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
