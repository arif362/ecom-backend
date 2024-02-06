### Get PIN code of CustomerOrder for partner
___

* **URL :** `BASE_URL + partner/api/v1/customer_order/:id/pin`

* **Method :** `GET`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "pin": "#{customer_order.pin}"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "error": "Couldn't find CustomerOrder with 'id'=#{customer_order.id}"
}
```
### Resend PIN code to customer
___

* **URL :** `BASE_URL + partner/api/v1/customer_order/resend_pin`

* **Method :** `GET`

* **URL Params :**

```json
{
  "order_id": 1234
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": "PIN sent successfully",
  "status_code": 200
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "error": "#{error_message}"
}
```
