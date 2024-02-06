**APP Force Update APIs for Rider app, Partner app, Ecom app, and SR app**
----

Get rider app version config:

* **URL**: ``BASE_URL + /rider/api/v1/app_config``

* **Method:** `GET`

* **URL Params:** ``

* **Success Response:**

 ```json
{
  "minimum_version": "1.0.0",
  "latest_version": "2.0.0",
  "is_android_published": true,
  "is_ios_published": true,
  "force_update": true
}
```
* **Code:** `200`
* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json
          { "message": "Rider app version config fetch failed.", "status_code": 422 }
         ```

Get partner app version config:

* **URL**: ``BASE_URL + /partner/api/v1/app_config``

* **Method:** `GET`

* **URL Params:** ``

* **Success Response:**

 ```json
{
  "minimum_version": "1.0.0",
  "latest_version": "2.0.0",
  "is_android_published": true,
  "is_ios_published": true,
  "force_update": true
}
```
* **Code:** `200`
* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json
          { "message": "Partner app version config fetch failed.", "status_code": 422 }
         ```

Get sr app version config:

* **URL**: ``BASE_URL + /api/v1/sales_representatives/app_config``

* **Method:** `GET`

* **URL Params:** ``

* **Success Response:**

 ```json
{
  "minimum_version": "1.0.0",
  "latest_version": "2.0.0",
  "is_android_published": true,
  "is_ios_published": true,
  "force_update": true
}
```
* **Code:** `200`
* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json
          { "message": "SR app version config fetch failed.", "status_code": 422 }
         ```

Get ecom app version config:

* **URL**: ``BASE_URL + /shop/api/v1/configurations/app_config``

* **Method:** `GET`

* **URL Params:** ``

* **Success Response:**

 ```json
{
  "minimum_version": "1.0.0",
  "latest_version": "2.0.0",
  "is_android_published": true,
  "is_ios_published": true,
  "force_update": true
}
```
* **Code:** `200`
* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json
          { "message": "Ecom app version config fetch failed.", "status_code": 422 }
         ```
