**Bank Account APIs**
----

### List of Bank Accounts for DH:

* **URL**: ``BASE_URL + /distributor/api/v1/bank_accounts``
* **Method:** `GET`
* **Authorization:** `DH admin`
* **Params:**

```json 
  ```

* **Success Response:**

```json 
  {
    "success": true,
    "status": 200,
    "message": "Successfully fetched bank accounts.",
    "data": [
    {
        "id": 1,
        "title": "EBL_demo_1",
        "bank_name": "EBL",
        "account_name": "demo_1",
        "branch_name": "Mohakhali"
    },
    {
        "id": 2,
        "title": "EBL_demo_2",
        "bank_name": "EBL",
        "account_name": "demo_2",
        "branch_name": "Mohakhali"
    }
        ]
}
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