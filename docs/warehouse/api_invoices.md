### Return list of products.
___

* **URL :** `BASE_URL + /api/v1/invoices/update_order_status`
* **Method :** `POST`
* **Header :** `Auth-token-sr`
* **URL Params :**

```json
{
  "invoice_id": 1235
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "order_id": 1235,
  "status": "In Transit",
  "status_type": "in_transit",
  "shipping_type": "Pick-up point",
  "order_type": "organic",
  "price": "4965.0",
  "warehouse_name": "Narshingdi",
  "distributor_name": "Virtual Distributor",
  "date": "2022-12-19T12:36:53.745+06:00",
  "prev_status": null,
  "business_type": "b2c"
}

```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "status_code": 404,
  "message": "This order is not ready for shipment"
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "status_code": 404,
  "message": "Wrong invoice scanned for SR or partner schedule not matched."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Invalid invoice scanned under this sr"
}
```
