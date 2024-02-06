### Customer Order Place
___
* **URL :** `BASE_URL + /partner/api/v1/order/place`
* **Method :** `POST`
* **URL Params :**

```json
{
  "phone": "0181234456",
  "first_name": "first_name",
  "last_name": "last_name",
  "pay_type": "nagad_payment"
}

```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
    "order_id": 1234,
    "customer_id": 12,
    "total_price": 1200
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to place order due to error_message",
  "status_code": 422
}
```
### Order statement
___
* **URL :** `BASE_URL + /partner/api/v1/order/statement`
* **Method :** `GET`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "received_from_sr": "3",
  "delivered_to_customer": "9",
  "delivery_remaining": "-6",
  "total_payment": "16840.0",
  "customer_paid": "16840.0",
  "paid_to_sr": "0",
  "remaining_payment": "16840.0",
  "total_returns": "5",
  "unpacked": "3 / 5",
  "packed": "0 / 0",
  "expired_orders": "0"
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to fetch statement",
  "status_code": 422
}
```
### Partner payment
___
* **URL :** `BASE_URL + /partner/api/v1/order/statement`
* **Method :** `GET`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "total_orders": "7",
  "organic_orders": "2 (TK. 30.0)",
  "induced_orders": "5 (TK. 0.0)",
  "total_margin": "30.0",
  "received_from_sr": "0.0",
  "organic_holding_fee": "15",
  "induced_holding_fee": "5"
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to fetch Payments",
  "status_code": 422
}
```


