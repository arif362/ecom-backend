### Get all area based on thana id
___

* **URL :** `BASE_URL + /shop/api/v1/areas`

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
    "message": "Successfully fetched area list.",
    "data": [
        {
            "id": 2075,
            "thana_id": 262,
            "name": "Zianagar",
            "bn_name": "জিয়ানগর",
            "home_delivery": true,
            "district_id": 13
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


