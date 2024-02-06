### Show all return reasons
___
* **URL :** `BASE_URL + customer_care/api/v1/return_orders/reasons`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "product is received in damaged/defective/incomplete condition":0,
  "product delivered is wrong":1,
  "product is different from the description on the website or not as advertised":2,
  "product arrives expired":3,
  "branded product is unsealed":4,
  "size or color is not a match":5,
  "warranty documents are missing despite stating on the website":6
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "#{error}"
}
```
