**Distributor APIs for finance**
----

### Get all distributors for Finance Admin:

* **URL**: ``BASE_URL + /finance/api/v1/distributors``
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
        "name": "Rafiq Enterprise",
        "bn_name": "রফিক এন্টারপ্রাইজ",
        "warehouse_id": 6,
        "email": "",
        "phone": "",
        "address": "",
        "code": "",
        "status": "inactive"
    },
    {
        "id": 3,
        "name": "Agami Member",
        "bn_name": "আগমী সদস্য",
        "warehouse_id": 7,
        "email": "",
        "phone": "",
        "address": "",
        "code": "",
        "status": "inactive"
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
  "message": "Unable to fetch distributors.",
  "data": {}
}
  ```

### Get distributor details for Finance Admin:

* **URL**: ``BASE_URL + /finance/api/v1/distributors/1``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
  ```

* **Success Response:**

```json 
{
    "id": 1,
    "name": "Rafiq Enterprise",
    "bn_name": "রফিক এন্টারপ্রাইজ",
    "warehouse_id": 6,
    "email": "",
    "phone": "",
    "address": "",
    "code": "",
    "status": "inactive"
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
  "message": "Unable to fetch distributor details.",
  "data": {}
}
  ```

### Get partner margins for Finance Admin:

* **URL**: ``BASE_URL + /finance/api/v1/distributors/26/partner_margins``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
    "month": 5, [required]
    "year": 2022, [required]
    "skip_pagination": true or false, [optional]
  ```

* **Success Response:**

```json 
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

### Get agent commission list for Finance Admin:

* **URL**: ``BASE_URL + /finance/api/v1/distributors/26/agent_commissions``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
    "month": 5, [required]
    "year": 2022, [required]
    "skip_pagination": true or false, [optional]
  ```

* **Success Response:**

```json 
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

### Get total commission and total partner margin:

* **URL**: ``BASE_URL + /finance/api/v1/distributors/26/total_commission_margin``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
    "month": 5, [required]
    "year": 2022, [required]
  ```

* **Success Response:**

```json 
{
   "status_code": 200,
   "total_partners_margin": 2167238,
   "pending_partners_margin": 83372,
   "paid_partners_margin": 467238,
   "total_fc_commission": 31983,
   "pending_fc_commission": 85432,
   "paid_fc_commission": 925373,
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
  "message": "Unable to calculate commissions due to .",
  "data": {}
}
  ```
