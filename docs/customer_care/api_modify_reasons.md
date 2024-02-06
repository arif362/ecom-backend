### Return list of all users as customers
___
* **URL :** `BASE_URL + customer_care/api/v1/modify_reasons`
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
  "success":true,
  "status":200,
  "message":"Successfully fetched reason list",
  "data":[
    {
      "id":10,
      "title":"Order korte chai",
      "title_bn":"Order korte chai bangla"
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
