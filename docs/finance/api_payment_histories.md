**Payment Histories APIs  for finance**
----

### Get payment histories for Finance Admin:

* **URL**: ``BASE_URL + /finance/api/v1/payment_histories``
* **Method:** `GET`
* **Authorization:** `Finance admin`
* **Params:**

```json 
{
    "skip_pagination": false, [optional]
    "warehouse_id": 1, [optional]
    "distributor_id": 2, [optional]
    "start_month": 5, [required]
    "end_month": 5, [required]
    "start_year": 2022, [required]
    "end_year": 2022, [required]
}
  ```

* **Success Response:**

```json 
{
    "total_fc_collection": 2826,
    "total_collection": 7326,
    "agent_commission": 2326,
    "total_fc_commission": 26,
    "total_partner_commission": 8726,
    "payment_histories": [
        {
            "id": 1,
            "warehouse_id": 8,
            "distributor_id": 6,
            "distributor_name": "Narshingdi",
            "month_and_year": 2022-09-01,
            "fc_total_collection": 27821,
            "total_collection": 122873,
            "fc_commission": 938,
            "agent_commission": 6723,
            "partner_commission": 623,
            "payable_amount": 63,
            "return_amount": 372,
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
  "message": "Unable to fetch payment history list.",
  "data": {}
}
  ```
