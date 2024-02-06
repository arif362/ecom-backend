### Get all thana based on district_id.
___

* **URL :** `BASE_URL + /shop/api/v1/thanas`
* **Method :** `GET`
* **URL Params :**

```json
{
  "district_id": 1,
  "pick_up_point": true,
  "warehouse_id": 8
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully fetched thana list.",
  "data":[
    {
      "id":4,
      "district_id":1,
      "name":"Abhaynagar",
      "bn_name":"অভয়নগর",
      "home_delivery":false
    },
    {
      "id":3,"district_id":1,
      "name":"Kahalu",
      "bn_name":"Kahalu",
      "home_delivery":false
    },
    {
      "id":1,
      "district_id":2,
      "name":"Palash",
      "bn_name":"Palash",
      "home_delivery":true
    },
    {
      "id":37,
      "district_id":1,
      "name":"dis-1 th-1",
      "bn_name":"dis-1 th-1",
      "home_delivery":true
    },
    {
      "id":6,
      "district_id":1,
      "name":"kafrul 28",
      "bn_name":"kafrul2",
      "home_delivery":true
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
   "message": "Unable to fetch thana list.",
   "data": {}
}
```
