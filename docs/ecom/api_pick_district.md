### Get all Districts.
___

* **URL :** `BASE_URL + /shop/api/v1/select/districts`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "warehouse_id": 35
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully fetched all districts.",
  "data":[
    {
      "district_id":3,
      "district_name":"Bogura",
      "bn_district_name":"bogura",
      "warehouse_id":49,
      "warehouse_name":"Dhaka",
      "sub_domain":"dhk",
      "warehouse_type":"member",
      "public_visibility":false
    },
    {
      "district_id":5,
      "district_name":"Dhaka",
      "bn_district_name":"Dhaka",
      "warehouse_id":52,
      "warehouse_name":"Prado distribution",
      "sub_domain":"",
      "warehouse_type":"distribution",
      "public_visibility":true
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
   "message": "Unable to fetch districts.",
   "data": {}
}
```
