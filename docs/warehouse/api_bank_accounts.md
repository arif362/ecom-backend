### Bank Account list
___

* **URL :** `BASE_URL + /api/v1/bank_accounts`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id": 3,
    "title": "Finance Admin",
    "bank_name": "EBL",
    "account_name": "Finance Admin",
    "branch_name": "Dhaka",
    "account_type": "Finance",
    "account_holder": "Finance"
  }
]
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch bank_account list",
   "data": {}
}
```

