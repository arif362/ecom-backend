**BankTransaction API's**
----
Deposit Amount

* **URL**: ``BASE_URL + /api/v1/bank_transactions``

* **Method:** `POST`

* **URL Params:**
   `{ 
   debit_bank_account_id: 1, type: Integer(optional)
   credit_bank_account_id: 2, type: Integer(requires)
   amount: 1000.00, type: BigDecimal(requires)
   chalan_no: "1, 3, 5", type: String(optional)
   start_date_time, type: DateTime(requires)
   end_date_time, type: DateTime(requires)
   images_file: [], type: ArrayOfImage(optional)
}`



* **Success Response:**
* **If phone and password matched:**
* **Code:** `200`
  * **Content:**
```json
{
 "message": "Successfully created bank transaction."
 "code": 200
}
```
* ** Error Response:**
* **Code:** `422`
  * **Content:**
```json
{
 "message": "Unable to fetch customer order list."
 "code": 422
}
```
