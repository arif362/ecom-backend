### Return Request list
___
* **URL :** `BASE_URL + /rider/api/v1/return/request_list`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "return_item_id": 897,
    "return_id": 897,
    "order_id": 5410,
    "customer_name": "Shopoth User",
    "customer_phone": "018xxxxxxxx",
    "shipping_address": {
      "area": "10 shoni tobga",
      "thana": "kafrul 28",
      "district": "Narshingdi",
      "phone": "018xxxxxxxx"
    },
    "return_status": "in_transit",
    "return_type": "unpacked",
    "initiated_by": "User"
  },
  {
    "return_item_id": 917,
    "return_id": 917,
    "order_id": 5477,
    "customer_name": "Shopoth User",
    "customer_phone": "018xxxxxxxx",
    "shipping_address": {
      "area": "10 shoni tobga",
      "thana": "kafrul 28",
      "district": "Narshingdi",
      "phone": "018xxxxxxxx"
    },
    "return_status": "in_transit",
    "return_type": "unpacked",
    "initiated_by": "User"
  }
]
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to find return_orders due to #{error}",
  "status_code": 422
}
```
### Fetch Order Payment History
___
* **URL :** `BASE_URL + /rider/api/v1/return/history`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "date": "16/08/2022",
    "order_list": [
      {
        "order_id": 917,
        "customer_name": "Shopoth User",
        "order_type": "organic",
        "business_type": "b2c",
        "app_order_type": "organic",
        "phone": "018xxxxxxxx",
        "amount": "4884.0",
        "area": "10 shoni tobga"
      }
    ]
  },
  {
    "date": "08/08/2022",
    "order_list": [
      {
        "order_id": 897,
        "customer_name": "Shopoth User",
        "order_type": "organic",
        "business_type": "b2c",
        "app_order_type": "organic",
        "phone": "018xxxxxxxx",
        "amount": "356.0",
        "area": "10 shoni tobga"
      }
    ]
  }
]
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to fetch return history due to #{ex.message}",
  "status_code": 422
}
```
### Return Order Details
___
* **URL :** `BASE_URL + /rider/api/v1/return/details`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "return_id": 917
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "return_id": 917,
  "return_date": "2022-08-16T17:00:15.879+06:00",
  "order_id": 5477,
  "customer_name": "Shopoth User",
  "customer_phone": "018xxxxxxxx",
  "return_status": "in_transit",
  "reason": "product arrives expired",
  "description": "",
  "items": [
    {
      "shopoth_line_item_id": 14287,
      "quantity": 1,
      "amount": "5000.0",
      "item": {
        "product_id": 3860,
        "product_title": "Kitkat",
        "product_attribute_value": "",
        "consumer_price": "5000.0"
      }
    }
  ]
}
 ```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Sorry return order with id: #{params[:return_id]} not found",
  "status_code": 404
}
```
### Collect Return order From Customer
___
* **URL :** `BASE_URL + /rider/api/v1/return/scan`
* **Method :** `POST`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "return_id": 917,
  "qr_code": "kitkat"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{ 
  "success": true, 
  "message": "Successfully return order received"
}
 ```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Return request not found or already refunded",
  "status_code": 404
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "You are not allowed to take this return",
  "status_code": 422
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Sorry! Return order can not be taken to in transit",
  "status_code": 404
}
```
