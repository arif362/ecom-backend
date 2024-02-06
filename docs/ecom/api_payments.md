### Initiate a payment through COD
___

* **URL :** `BASE_URL + /shop/api/v1/payment/cash_on_delivery/initiate`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "order_id": 4321
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "successful",
  "data": {}
}
```
### Update the COD Payment as successful after delivery
___

* **URL :** `BASE_URL + /shop/api/v1/payment/cash_on_delivery/finalize`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "tran_id": "666",
  "currency_type": "BDT",
  "currency_amount": "200"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "successful",
  "data": {}
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "#{error}",
   "data": {}
}
```
### Initiate a payment through Credit Card.
___

* **URL :** `BASE_URL + /shop/api/v1/payment/credit_card/initiate`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "order_id": 4321
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully initialized payment .",
  "data": {}
}
```

* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "#{error}",
   "data": {}
}
```
### GET: Listen to Instant Payment Notification(IPN) from SSLCOMMERZ
___

* **URL :** `BASE_URL + /shop/api/v1/payment/credit_card/ipn`
* **Method :** `GET`
* **URL Params :**

```json
{
  "status": "pending",
  "tran_id": "666",
  "currency_type": "BDT",
  "currency_amount": "200"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "IPN request successfully validated Transaction: #{order.id}",
  "data": {}
}
```
### POST: Listen to Instant Payment Notification(IPN) from SSLCOMMERZ
___

* **URL :** `BASE_URL + /shop/api/v1/payment/credit_card/ipn`
* **Method :** `POST`
* **URL Params :**

```json
{
  "status": "pending",
  "tran_id": "666",
  "currency_type": "BDT",
  "currency_amount": "200"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "IPN request successfully validated Transaction: #{order.id}",
  "data": {}
}
```

* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "IPN request could not validate Transaction: #{order.id}",
   "data": {}
}
```
