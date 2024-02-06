**BankTransaction APIs for finance**
----

### List of Bank Transactions for Finance Admin:

* **URL**: ``BASE_URL + /finance/api/v1/bank_transactions``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
{
    "start_date_time": "01-07-2022", [optional]
    "end_date_time": "31-07-2022", [optional]
    "distributor_id": 26, [optional] before: warehouse_id
}
  ```

* **Success Response:**

```json 
[
    {
        "id": 1254,
        "warehouse_name": "Khulna FC",
        "collection_date": "2022-06-12",
        "amount": "16631.0",
        "to_bank": "Eastern Bank Limited",
        "from_bank": null,
        "order_count": 41,
        "is_approved": false,
        "chalan_no": "8770"
    },
    {
        "id": 1221,
        "warehouse_name": "Khulna FC",
        "collection_date": "2022-06-09",
        "amount": "4002.0",
        "to_bank": "Eastern Bank Limited",
        "from_bank": null,
        "order_count": 10,
        "is_approved": false,
        "chalan_no": "761"
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
  "message": "Unable to fetch bank transactions.",
  "data": {}
}
  ```

### Export Bank Transactions for Finance Admin:

* **URL**: ``BASE_URL + /finance/api/v1/bank_transactions/export``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
{
    "start_date_time": "01-07-2022", [optional]
    "end_date_time": "31-07-2022", [optional]
    "distributor_id": 26, [optional] before: warehouse_id
}
  ```

* **Success Response:**

```json 
[
    {
        "id": 1254,
        "warehouse_name": "Khulna FC",
        "collection_date": "2022-06-12",
        "amount": "16631.0",
        "to_bank": "Eastern Bank Limited",
        "from_bank": null,
        "order_count": 41,
        "is_approved": false,
        "chalan_no": "8770"
    },
    {
        "id": 1221,
        "warehouse_name": "Khulna FC",
        "collection_date": "2022-06-09",
        "amount": "4002.0",
        "to_bank": "Eastern Bank Limited",
        "from_bank": null,
        "order_count": 10,
        "is_approved": false,
        "chalan_no": "761"
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
  "message": "Unable to export bank transactions.",
  "data": {}
}
  ```

### List of Commission Bank Transactions for Finance Admin:

* **URL**: ``BASE_URL + /finance/api/v1/bank_transactions/commissions``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
{
    "month": 5, [requires]
    "year": 2022, [requires]
    "distributor_id": 26, [optional] before: warehouse_id
    "transaction_type": 1 or 2, [optional]
}
  ```

* **Success Response:**

```json 
[
    {
        "transaction_id": 694,
        "warehouse_name": "Dhaka FC",
        "collection_date": "2022-05-18",
        "amount": "6151.5",
        "to_bank": "Al-Arfah islami Bank ltd",
        "from_bank": "Eastern Bank Limited",
        "order_count": 1250,
        "is_approved": false,
        "chalan_no": "256100477, 256100478",
        "transaction_type": "agent_commission"
    },
    {
        "transaction_id": 696,
        "warehouse_name": "Khulna FC",
        "collection_date": "2022-05-18",
        "amount": "9063.11",
        "to_bank": "First Security Islami Bank",
        "from_bank": "Eastern Bank Limited",
        "order_count": 1687,
        "is_approved": false,
        "chalan_no": "256100480",
        "transaction_type": "agent_commission"
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
  "message": "Unable to fetch commissions.",
  "data": {}
}
  ```

### List of Supplier Payment for Finance Admin:

* **URL**: ``BASE_URL + /finance/api/v1/bank_transactions/get_supplier_payment``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
{
    "supplier_id": 5, [optional]
    "start_date_time": "01-05-2022", [optional]
    "end_date_time": "31-05-2022", [optional]
}
  ```

* **Success Response:**

```json 
[
    {
        "id": 694,
        "chalan_no": "hsdja26378923",
        "created_at": "2022-05-18",
        "supplier_name": "Uniliver",
        "supplier_id": 12,
        "amount": 1250,
        "credit_bank_name": "Eastern Bank Limited",
        "credit_bank_branch_name": "Banani",
        "debit_bank_name": "Eastern Bank Limited",
        "debit_bank_branch_name": "Gulshan",
    },
    {
        "id": 695,
        "chalan_no": "ja26378923",
        "created_at": "2022-05-19",
        "supplier_name": "Uniliver",
        "supplier_id": 21,
        "amount": 1250,
        "credit_bank_name": "Eastern Bank Limited",
        "credit_bank_branch_name": "Banani",
        "debit_bank_name": "Eastern Bank Limited",
        "debit_bank_branch_name": "Gulshan",
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
  "message": "Unable to fetch supplier payments.",
  "data": {}
}
  ```

### Export Supplier Payments for Finance Admin:

* **URL**: ``BASE_URL + /finance/api/v1/bank_transactions/export_supplier_payment``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
{
    "supplier_id": 5, [optional]
    "start_date_time": "01-05-2022", [optional]
    "end_date_time": "31-05-2022", [optional]
}
  ```

* **Success Response:**

```json 
[
    {
        "id": 694,
        "chalan_no": "hsdja26378923",
        "created_at": "2022-05-18",
        "supplier_name": "Uniliver",
        "supplier_id": 12,
        "amount": 1250,
        "credit_bank_name": "Eastern Bank Limited",
        "credit_bank_branch_name": "Banani",
        "debit_bank_name": "Eastern Bank Limited",
        "debit_bank_branch_name": "Gulshan",
    },
    {
        "id": 695,
        "chalan_no": "ja26378923",
        "created_at": "2022-05-19",
        "supplier_name": "Uniliver",
        "supplier_id": 21,
        "amount": 1250,
        "credit_bank_name": "Eastern Bank Limited",
        "credit_bank_branch_name": "Banani",
        "debit_bank_name": "Eastern Bank Limited",
        "debit_bank_branch_name": "Gulshan",
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
  "message": "Unable to export supplier payments.",
  "data": {}
}
  ```

### Get details of a specific Bank Transactions for Finance:

* **URL**: ``BASE_URL + /finance/api/v1/bank_transactions/699``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
  ```

* **Success Response:**

```json 
{
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

### Pay supplier payments for Finance Admin:

* **URL**: ``BASE_URL + /finance/api/v1/bank_transactions/supplier_payment``
* **Method:** `POST`
* **Authorization:** `Finance admin`
* **Params:**

```json 
{
    "debit_bank_account_id": 5, [required]
    "credit_bank_account_id": 12, [required]
    "purchase_order_id": 32, [required]
    "amount": 1230, [required]
    "chalan_no": "jsd238743", [required]
    "image_file": File, [optional]
}
  ```

* **Success Response:**

```json 
{
    "message": "Successfully created supplier payment.",
    "status_code": 201,
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
  "message": "Unable to create supplier payment.",
  "data": {}
}
  ```

### Pay pending commission and margin to DH:

* **URL**: ``BASE_URL + /finance/api/v1/bank_transactions/pay_commission``
* **Method:** `POST`
* **Authorization:** `Finance admin`
* **Params:**

```json 
{
    "distributor_id": 26, [required]
    "month": 5, [required]
    "year": 2022, [required]
    "debit_bank_account_id": 5, [required]
    "credit_bank_account_id": 12, [required]
    "chalan_no": "jsd238743", [required]
    "transaction_type": ["agent_commission" or "sub_agent_commission"], [required]
    "image_file": File, [required]
}
  ```

* **Success Response:**

```json 
{
    "message": "Successfully created bank transaction.",
    "status_code": 201,
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

### Receive Bank Transaction:

* **URL**: ``BASE_URL + /finance/api/v1/bank_transactions/receive/:id``
* **Method:** `PUT`
* **Authorization:** `Finance admin`
* **Params:**

```json 
  ```

* **Success Response:**

```json 
{
    "message": "Successfully approved bank transaction.",
    "status_code": 200,
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
  "message": "Unable to approve bank transaction.",
  "data": {}
}
  ```

### Get partners margins for Finance:

* **URL**: ``BASE_URL + /finance/api/v1/bank_transactions/699/partners_margin_list``

* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
  ```

* **Success Response:**

```json 
[
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

### Get agent commissions for Finance:

* **URL**: ``BASE_URL + /finance/api/v1/bank_transactions/699/agent_commission_list``

* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
  ```

* **Success Response:**

```json 
[
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