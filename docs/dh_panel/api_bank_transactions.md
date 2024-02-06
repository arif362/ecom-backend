**Commission Disbursement APIs**
----

### Get all BankTransactions for DH panel:

* **URL**: ``BASE_URL + /distributor/api/v1/bank_transactions``

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
    "data": [
        {
            "id": 699,
            "warehouse_name": "Salahuddin rakib",
            "amount": "24418.25",
            "chalan_no": "256100484, 256100486",
            "to_bank": "AB Bank Ltd",
            "from_bank": "Eastern Bank Limited",
            "is_approved": true,
            "order_count": 1205,
            "collection_date": "2022-05-18"
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

### Details of a specific Bank Transactions for DH panel:

* **URL**: ``BASE_URL + /distributor/api/v1/bank_transactions/:id``

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
        "transaction_id": 699,
        "warehouse_name": "Salahuddin rakib",
        "collection_date": "2022-05-18",
        "amount": "24418.25",
        "to_bank": "AB Bank Ltd",
        "from_bank": "Eastern Bank Limited",
        "is_approved": true,
        "slip": null,
        "transaction_type": "sub_agent_commission",
        "customer_orders": [
            {
                "id": 42233,
                "reconciled_date": "2022-04-06T17:50:20.583+06:00",
                "amount": "180.0",
                "shipping_type": "pick_up_point",
                "is_paid": true
            },
            {
                "id": 42551,
                "reconciled_date": "2022-04-18T19:55:14.972+06:00",
                "amount": "180.0",
                "shipping_type": "pick_up_point",
                "is_paid": true
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

### List of Commission Bank Transactions for DH panel:

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
    "message": "Successfully fetched agent commissions.",
    "data": [
        {
            "transaction_id": 698,
            "warehouse_name": "Salahuddin rakib",
            "collection_date": "2022-05-18",
            "amount": "7888.83",
            "to_bank": "AB Bank Ltd",
            "from_bank": "Eastern Bank Limited",
            "order_count": 1205,
            "is_approved": false,
            "chalan_no": "256100479, 256100481",
            "transaction_type": "agent_commission"
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
  "message": "Unable to fetch agent commissions.",
  "data": {}
}
  ```

### Get partner margins for DH panel:

* **URL**: ``BASE_URL + /distributor/api/v1/bank_transactions/699/partner_margins``

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
    "message": "Successfully fetched partner margins.",
    "data": [
        {
            "order_id": 51481,
            "created_at": "2022-04-07T09:31:12.094+06:00",
            "completed_at": "2022-04-10T00:00:00.000+06:00",
            "order_type": "induced",
            "shipping_type": "pick_up_point",
            "customer_name": "Sr Humayun Kabir Araihazar",
            "phone": "01922427529",
            "price_before_discount": "350.0",
            "discount_amount": "0.0",
            "price_after_discount": "350.0",
            "partner_id": 549,
            "partner_name": "JR Corporation FC",
            "partner_commission": "0.0"
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
  "message": "Unable to fetch partner margins.",
  "data": {}
}
  ```

### Get agent commissions for DH panel:

* **URL**: ``BASE_URL + /distributor/api/v1/bank_transactions/699/agent_commissions``

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
    "message": "Successfully fetched agent commissions.",
    "data": [
        {
            "order_id": 48538,
            "created_at": "2022-03-20T18:49:13.486+06:00",
            "completed_at": "2022-04-12T09:59:53.366+06:00",
            "order_type": "induced",
            "shipping_type": "pick_up_point",
            "customer_name": "Md Masud",
            "phone": "01747232648",
            "price_before_discount": "456.0",
            "discount_amount": "0.0",
            "price_after_discount": "456.0",
            "agent_commission": "6.84"
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
  "message": "Unable to fetch agent commissions.",
  "data": {}
}
  ```

### Create DH Bank Transactions to Finance:

* **URL**: ``BASE_URL + /distributor/api/v1/bank_transactions``

* **Method:** `POST`
* **Authorization:** `DH admin`
* **Params:**

```json 
{
“debit_bank_account_id”: 2, [optional]
“credit_bank_account_id”: 2,
“amount”: 351,
“chalan_no”: “123456, 12452”, 	//Comma separated multiple chalan_no in string 
“start_date_time”: "01-07-2022",
“end_date_time”: "31-07-2022",
“images_file”: [] 		//ArrayOfImage
}
  ```

* **Success Response:**

```json 
  {
    "success": true,
    "status": 201,
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

### Collect agent and sub_agent commission from Finance on DH panel:

* **URL**: ``BASE_URL + /distributor/api/v1/bank_transactions/collect_commission``

* **Method:** `PUT`
* **Authorization:** `DH admin`
* **Params:**

```json 
{
“bank_transaction_id”: 2, 
“transaction_type”: agent_commission or sub_agent_commission,
}
  ```

* **Success Response:**

```json 
  {
    "success": true,
    "status": 201,
    "message": "Commission collected successfully.",
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
  "message": "Unable to collect commission.",
  "data": {}
}
  ```