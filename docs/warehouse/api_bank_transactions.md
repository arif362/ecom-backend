### Bank Transaction list
___

* **URL :** `BASE_URL + /api/v1/bank_transactions`
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
    "id": 43,
    "warehouse_name": "Central WareHouse",
    "amount": "2105.13",
    "chalan_no": "1111",
    "to_bank": "EBL",
    "from_bank": "EBL",
    "is_approved": false,
    "order_count": 49,
    "collection_date": "2022-03-08"
  },
  {
    "id": 38,
    "warehouse_name": "Central WareHouse",
    "amount": "2154.15",
    "chalan_no": "Sub agent payment",
    "to_bank": "EBL",
    "from_bank": "EBL",
    "is_approved": true,
    "order_count": 24,
    "collection_date": "2022-01-30"
  },
  {
    "id": 37,
    "warehouse_name": "Central WareHouse",
    "amount": "904.6",
    "chalan_no": "decimal",
    "to_bank": "EBL",
    "from_bank": "EBL",
    "is_approved": false,
    "order_count": 17,
    "collection_date": "2022-01-30"
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
   "message": "Unable to fetch bank_transaction list",
   "data": {}
}
```
### List of Commission Bank Transactions for Warehouse admin.
___

* **URL :** `BASE_URL + /api/v1/bank_transactions/commissions`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "month": 12,
  "year": 2022
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[]
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch bank transaction list.",
   "data": {}
}
```

