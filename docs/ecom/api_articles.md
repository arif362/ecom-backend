### Fetch article list
___

* **URL :** `BASE_URL + /shop/api/v1/articles/search`

* **Method :** `GET`

* **URL Params :**

```json
{
    "thana_id": 262,
    "pick_up_point": false
}
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
            "id": 6,
            "title": "Account Deactivation Note",
            "slug": "account-deactivation-note",
            "bn_title": "Account Deactivation Note",
            "body": "<p><strong>How can I deactivate or delete my account?<br></strong><br>If you'd like to deactivate or delete your shopoth account, simply fill up the account deactivation and deletion form and refer to the steps below: <br><br>1. Initiate your request by filling out the form<br>2. You'll receive a call within 72 hours for verification<br>3. Your account will be deactivated or deleted as requested</p>",
            "bn_body": "<p><strong>How can I deactivate or delete my account?<br></strong><br>If you'd like to deactivate or delete your shopoth account, simply fill up the account deactivation and deletion form and refer to the steps below: <br><br>1. Initiate your request by filling out the form<br>2. You'll receive a call within 72 hours for verification<br>3. Your account will be deactivated or deleted as requested</p>",
            "position": 0,
            "help_topic_id": 6,
            "help_topic_name": "Account Deactivation & Deletion Information",
            "help_topic_slug": "account-deactivation-deletion-information"
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
   "message": "Unable to fetch area list.",
   "data": {}
}
```
### Fetch article details
___

* **URL :** `BASE_URL + /shop/api/v1/articles/:id`

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
    "message": "Successfully Fetch",
    "data": {
        "id": 6,
        "title": "Account Deactivation Note",
        "slug": "account-deactivation-note",
        "bn_title": "Account Deactivation Note",
        "body": "<p><strong>How can I deactivate or delete my account?<br></strong><br>If you'd like to deactivate or delete your shopoth account, simply fill up the account deactivation and deletion form and refer to the steps below: <br><br>1. Initiate your request by filling out the form<br>2. You'll receive a call within 72 hours for verification<br>3. Your account will be deactivated or deleted as requested</p>",
        "bn_body": "<p><strong>How can I deactivate or delete my account?<br></strong><br>If you'd like to deactivate or delete your shopoth account, simply fill up the account deactivation and deletion form and refer to the steps below: <br><br>1. Initiate your request by filling out the form<br>2. You'll receive a call within 72 hours for verification<br>3. Your account will be deactivated or deleted as requested</p>",
        "position": 0,
        "help_topic_id": 6,
        "help_topic_name": "Account Deactivation & Deletion Information",
        "help_topic_slug": "account-deactivation-deletion-information"
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
   "message": "Failed to fetch",
   "data": {}
}
```


