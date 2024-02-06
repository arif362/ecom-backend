**Bank Account APIs  for finance**
----

### List of Bank Accounts for finance:

* **URL**: ``BASE_URL + /finance/api/v1/bank_accounts``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
  ```

* **Success Response:**

```json 
[
    {
        "id": 1,
        "title": "EBL_Master Account",
        "bank_name": "Eastern Bank Limited",
        "account_name": "AGAMI LIMITED",
        "branch_name": "Head Office, 100 Gulshan Avenue, Gulshan, Dhaka.",
        "account_type": "Finance",
        "account_holder": "Finance"
    },
    {
        "id": 2,
        "title": "EBL_Sales Collection",
        "bank_name": "Eastern Bank Limited",
        "account_name": "AGAMI LIMITED",
        "branch_name": "Head Office, 100 Gulshan Avenue, Gulshan, Dhaka.",
        "account_type": "Finance",
        "account_holder": "Finance"
    }
]
  ```

* **Code:** `200`
* **Error Response:**
* **Code:** `422`
* **Content:**

```json 
{
  "success": false,
  "status": 200,
  "message": "Unable to fetch bank accounts.",
  "data": {}
}
  ```

### List of all Bank Accounts based on account_type for Finance:

* **URL**: ``BASE_URL + /finance/api/v1/bank_accounts/list``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
  ```

* **Success Response:**

```json 
[
    {
        "id": 1,
        "title": "EBL_Master Account",
        "bank_name": "Eastern Bank Limited",
        "account_name": "AGAMI LIMITED",
        "branch_name": "Head Office, 100 Gulshan Avenue, Gulshan, Dhaka.",
        "account_type": "Finance",
        "account_holder": "Finance"
    },
    {
        "id": 2,
        "title": "EBL_Sales Collection",
        "bank_name": "Eastern Bank Limited",
        "account_name": "AGAMI LIMITED",
        "branch_name": "Head Office, 100 Gulshan Avenue, Gulshan, Dhaka.",
        "account_type": "Finance",
        "account_holder": "Finance"
    }
]
  ```

* **Code:** `200`
* **Error Response:**
* **Code:** `422`
* **Content:**

```json 
{
  "success": false,
  "status": 200,
  "message": "Unable to fetch bank accounts.",
  "data": {}
}
  ```