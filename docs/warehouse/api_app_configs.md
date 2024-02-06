### App version update.
___

* **URL :** `BASE_URL + /api/v1/app_configs/version`
* **Method :** `PUT`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "app_type": "ecom_app",
  "version_config": {
    "minimum_version": "1.0.50",
    "latest_version": "1.0.50",
    "is_android_published":true,
    "is_ios_published":true,
    "force_update": true
  }
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully updated app configuration.",
  "data": {}
}
```
* **Error Response**
* **Code :**`406`
* **Content :**
```json
{
   "success": false,
   "status": 406,
   "message": "Please provide app type like: 'sr_app or rider_app or partner_app or ecom_app'",
   "data": {}
}
```
* **Error Response**
* **Code :**`406`
* **Content :**
```json
{
   "success": false,
   "status": 406,
   "message": "App configuration not found.",
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
   "message": "Unable to update app configuration",
   "data": {}
}
```
