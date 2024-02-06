**User Preference's API (Ecom)**
----
-> View User's Preferences

* **URL**: ``BASE_URL + /shop/api/v1/user_preferences``

* **Method:** `GET`

* **Success Response:**
 ```json
{
  "id": 1,
  "default_delivery_method": "default_pickup_point",
  "mail_notification": "email",
  "smart_notification": "push",
  "cellular_notification": "sms",
  "subscription": "newsletter"
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Error detail", 500 }
         ```   

-> Create/Update User's Preferences

* **URL**: ``BASE_URL + /shop/api/v1/user_preferences``

* **Method:** `POST`

*  **URL Params:**
   `{ "default_delivery_method(optional)": "cod"/"default_pickup_point"/"home_delivery",
   "mail_notification(optional)": "email"/"no_email",
   "smart_notification(optional)": "push"/"no_push",
   "cellular_notification(optional)": "sms"/"no_sms",
   "subscription(optional)": "newsletter"/"no_newsletter",
   }`

* **Success Response:**
 ```json
{
  "message": "Succesfully Created",
  "status_code": 200
}
```
 ```json
{
  "message": "Succesfully Updated",
  "status_code": 200
}
```

* **Code:** `201`, `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**
         ```json 
          { "message": "Error detail", 500 }
         ```

-> Delete Operation is redundant for this so no implementation for now.
