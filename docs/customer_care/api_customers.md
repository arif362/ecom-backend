### Return list of all users as customers
___
* **URL :** `BASE_URL + customer_care/api/v1/customers`
* **Method :** `GET`
* * **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id":730,
    "name":"Shopoth User",
    "email":null,
    "phone":"0176xxxxxxx",
    "status":"active",
    "addresses":[]
  },
  {
    "id":728,
    "name":"Md Shahriar Mahmud",
    "email":"shah14@gmail.com",
    "phone":"017xxxxxxx",
    "status":"active",
    "addresses":[]
  }
]
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to return customer list due to #{ex.message}"
}
```
### Get customer details
___
* **URL :** `BASE_URL + customer_care/api/v1/customers/:id`
* **Method :** `GET`
* * **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "id":730,
  "name":"Shopoth User",
  "joined_at":"2022-12-26T14:21:31.800+06:00",
  "email":null,
  "phone":"0176xxxxxxxx",
  "status":"active",
  "addresses":[],
  "customer_orders":[],
  "return_customer_orders":[],
  "coupons":[]
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to return details due to #{error.message}"
}
```
