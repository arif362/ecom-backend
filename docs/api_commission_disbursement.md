**Commission Disbursement APIs**
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

### Reconciled customer order list for Distribution warehouse:

* **URL**: ``BASE_URL + /distributor/api/v1/customer_orders/reconciled?start_date_time=2021-07-28&end_date_time=2021-07-30``

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
    "message": "Successfully fetched reconciled customer orders.",
    "data": 
    {
    "total_collected_amount": "94207.0",
    "total_deposited_amount": "70.0",
    "due_amount": "94137.0",
    "orders": 
    [
        {
            "id": 1729,
            "reconciled_date": "2021-07-05T16:17:16.213+06:00",
            "amount": "70.0",
            "shipping_type": "pick_up_point",
            "is_paid": true
        },
        {
            "id": 1731,
            "reconciled_date": "2021-07-05T16:17:16.273+06:00",
            "amount": "69.0",
            "shipping_type": "pick_up_point",
            "is_paid": false
        },
        {
            "id": 1732,
            "reconciled_date": "2021-07-05T16:17:16.292+06:00",
            "amount": "3000.0",
            "shipping_type": "pick_up_point",
            "is_paid": false
        }
    ]
    }
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
  "message": "Unable to fetch reconciled customer orders.",
  "data": {}
}
  ```

### Get all BankTransactions:

* **
URL**: ``BASE_URL + /distributor/api/v1/bank_transactions``

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
    "message": "Successfully fetched bank transactions.",
    "data": 
    [
    {
        "id": 1,
        "amount": 351,
        "chalan_no": "",
        "bank": "EBL",
        "is_approved": true,
        "order_count": 2,
        "created_at": "2021-08-09T17:57:07.079+06:00"
    },
    {
        "id": 1,
        "amount": 351,
        "chalan_no": "",
        "bank": "EBL",
        "is_approved": true,
        "order_count": 2,
        "created_at": "2021-08-09T17:57:07.079+06:00"
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
  "message": "Unable to fetch bank transactions.",
  "data": {}
}
  ```

### Export all BankTransactions:

* **
URL**: ``BASE_URL + /distributor/api/v1/bank_transactions/export``

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
    "message": "Successfully fetched bank transactions.",
    "data": 
    [
    {
        "id": 1,
        "amount": 351,
        "chalan_no": "",
        "bank": "EBL",
        "is_approved": true,
        "order_count": 2,
        "created_at": "2021-08-09T17:57:07.079+06:00"
    },
    {
        "id": 1,
        "amount": 351,
        "chalan_no": "",
        "bank": "EBL",
        "is_approved": true,
        "order_count": 2,
        "created_at": "2021-08-09T17:57:07.079+06:00"
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
  "message": "Unable to fetch bank transactions.",
  "data": {}
}
  ```

### Details of a specific Bank Transactions for DH:

* **
URL**: ``BASE_URL + /distributor/api/v1/bank_transactions/:id``

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
    "message": "Successfully fetched bank transaction details.",
    "data": {
    "id": 1,
    "warehouse_name": "Narsingdi",
    "collection_date": "2021-08-09",
    "amount": 351,
    "bank": "EBL",
    "is_approved": true,
    "slip": "http://localhost:3000/rails/active_storage/disk/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdDRG9JYTJWNVNTSnJkbUZ5YVdGdWRITXZaVFV4ZVdka1pEbG1NRE5xTm5WdGFXbHhlVGxvTVhweWFIbG5ieTgxTjJNNFkyUXhaams1TlRVeVpEWXdZakl6WkRRNFlXVm1NV0k0TXpnM1pqTmpZamN6WWpJM1pEQmpOamxqTUdZMVkyVTVPVE5tTVRFME16Y3dNelppQmpvR1JWUTZFR1JwYzNCdmMybDBhVzl1U1NKSmFXNXNhVzVsT3lCbWFXeGxibUZ0WlQwaU1USXdNQ1V5UVRZd01DNXFjR1ZuSWpzZ1ptbHNaVzVoYldVcVBWVlVSaTA0SnljeE1qQXdKVEpCTmpBd0xtcHdaV2NHT3daVU9oRmpiMjUwWlc1MFgzUjVjR1ZKSWc5cGJXRm5aUzlxY0dWbkJqc0dWQT09IiwiZXhwIjoiMjAyMS0wOC0xMFQxMjoyMToxNy40NTJaIiwicHVyIjoiYmxvYl9rZXkifX0=--ef8cf242faf2261eb54e046f7876053efe9808a4/1200*600.jpeg?content_type=image%2Fjpeg&disposition=inline%3B+filename%3D%221200%252A600.jpeg%22%3B+filename%2A%3DUTF-8%27%271200%252A600.jpeg",
    "customer_orders": [
        {
            "order_id": "0003055",
            "reconciled_date": "2021-07-29T12:17:11.299+06:00",
            "amount": "160.0",
            "shipping_type": "pick_up_point"
        },
        {
            "order_id": "0003144",
            "reconciled_date": "2021-07-29T11:34:23.411+06:00",
            "amount": "191.0",
            "shipping_type": "pick_up_point"
        }
    ]
}
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
  "message": "Unable to fetch bank transaction details.",
  "data": {}
}
  ```

### Create DH Bank Transactions to Finance:

* **
URL**: ``BASE_URL + /distributor/api/v1/bank_transactions``

* **Method:** `POST`
* **Authorization:** `DH admin`
* **Params:**

```json 
{
“debit_bank_account_id”: 2, [optional]
“credit_bank_account_id”: 2,
“chalan_no”: “123456, 12452”, 	//Comma separated multiple chalan_no in string 
“amount”: 351,
“customer_order_ids”: [3055, 3144],
“images_file”: [] 		//ArrayOfImage
}
  ```

* **Success Response:**

```json 
  {
    "success": true,
    "status": 200,
    "message": "Successfully created bank transaction.",
    "data": {}
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
  "message": "Unable to create bank transaction.",
  "data": {}
}
  ```

### List of Commission Bank Transactions for DH:

* **URL**: ``BASE_URL + /distributor/api/v1/bank_transactions/commissions``

* **Method:** `GET`
* **Authorization:** `DH admin`
* **Params:**

```json 
{
“month”: 6,
“year”: 2021,
“transaction_type”: 1/2 (optional) [agent_commission: 1, sub_agent_commission: 2]
}
  ```

* **Success Response:**

```json 
  {
    "success": true,
    "status": 200,
    "message": "Successfully fetched bank transactions.",
    "data": [
    {
        "transaction_id": 1,
        "warehouse_name": “Narshigdi”,,
        "collection_date": "2021-08-09T17:57:07.079+06:00"
        "amount": 351,
        "chalan_no": "",
        "to_bank": "EBL",
        "from_bank": "EBL",
        "is_approved": true,
        "order_count": 2,
        "transaction_type": ‘agent_commission’
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
  "message": "Unable to fetch bank transactions.",
  "data": {}
}
  ```
