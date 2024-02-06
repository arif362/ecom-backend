### Request for full parcel return.
___

* **URL :** `BASE_URL + partner/api/v1/return/full_parcel`

* **Method :** `POST`

* **URL Params :**

```json
{
  "order_id": "2365",
  "reason": "Product is Damaged",
  "description":  "Product is Damaged"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "message": "Order return request initiated successfully."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "message": "Wrong order invoice scanned."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "You are scanning invalid product."
}
```
### Request for partial return
___

* **URL :** `BASE_URL + partner/api/v1/return/partial`

* **Method :** `POST`

* **URL Params :**

```json
{
  "order_id": "2365",
  "qr_code": "kitkat",
  "reason": "Product is Damaged",
  "description":  "Product is Damaged"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "message": "Order return request initiated successfully."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "message": "Wrong request of qr codes or already in partner."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "message": "After 7 days, the product cannot be returned."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "You are scanning invalid product."
}
```
### Return Request list
___

* **URL :** `BASE_URL + partner/api/v1/return/request_list`

* **Method :** `GET`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "return_id": 960,
    "order_id": 5578,
    "customer": {
      "name": "beautiful day ",
      "phone": "0170xxxxxxx"
    },
    "return_status": "initiated",
    "app_return_status": "initiated",
    "return_type": "unpacked",
    "business_type": "b2c",
    "app_return_type": "unpacked",
    "initiated_by": "User",
    "app_initiated_by": "User"
  },
  {
    "return_id": 988,
    "order_id": 5781,
    "customer": {
      "name": null,
      "phone": null
    },
    "return_status": "in_partner",
    "app_return_status": "in_partner",
    "return_type": "packed",
    "business_type": "b2c",
    "app_return_type": "packed",
    "initiated_by": "Partner",
    "app_initiated_by": "Partner"
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
   "status_code": 404,
   "message": "Unable to fetch return order"
}
```
### Returned to SR list.
___

* **URL :** `BASE_URL + partner/api/v1/return/completed_list`

* **Method :** `GET`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "return_id": 961,
    "order_id": 5580,
    "customer": {
      "name": "beautiful day ",
      "phone": "0170xxxxxxx"
    },
    "return_status": "completed",
    "app_return_status": "completed",
    "return_type": "unpacked",
    "business_type": "b2c",
    "app_return_type": "unpacked",
    "initiated_by": "User",
    "app_initiated_by": "User"
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
   "status_code": 404,
   "message": "Unable to fetch return order"
}
```
### Return Order Details
___

* **URL :** `BASE_URL + partner/api/v1/return/details`

* **Method :** `GET`

* **URL Params :**

```json
{
  "return_id": 960
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "return_id": 960,
  "return_date": "2022-08-31T18:29:25.177+06:00",
  "order_id": 5578,
  "customer": {
    "name": "beautiful day ",
    "phone": "0170xxxxxxx"
  },
  "return_status": "initiated",
  "app_return_status": "initiated",
  "reason": "product is received in damaged/defective/incomplete condition",
  "app_reason": "product is received in damaged/defective/incomplete condition",
  "description": "gty",
  "quantity": null,
  "business_type": "b2c",
  "items": [
    {
      "shopoth_line_item_id": 14423,
      "quantity": 1,
      "amount": "4884.0",
      "item": {
        "product_id": 3860,
        "product_title": "Kitkat",
        "product_attribute_value": "",
        "consumer_price": "4884.0"
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
   "status_code": 404,
   "message": "Unable to show return_order details."
}
```
### Details for Return item
___

* **URL :** `BASE_URL + partner/api/v1/return/order_details`

* **Method :** `GET`

* **URL Params :**

```json
{
  "order_id": 6097,
  "scan_code": "kitkat",
  "return_type": "unpacked"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "order_id": 6097,
  "order_date": "2022-12-12T16:09:36.977+06:00",
  "customer": {
    "name": "Honda Seller Storeeee",
    "phone": "016xxxxxxx"
  },
  "order_type": "induced",
  "order_status": "returned_from_customer",
  "shopoth_line_items": [
    {
      "line_item_id": 15355,
      "item": {
        "product_title": "Kitkat",
        "product_attribute_values": []
      },
      "quantity": 1,
      "price": {
        "retailer_price": "4850.0",
        "consumer_price": "4000.0",
        "partner_margin": "150.0"
      }
    }
  ],
  "total_price": {
    "retailer_price": "4850.0",
    "consumer_price": "5000.0",
    "b2b_price": "4500.0",
    "partner_margin": "150.0"
  },
  "return_reasons": [
    {
      "value": 0,
      "text": "product is received in damaged/defective/incomplete condition"
    },
    {
      "value": 1,
      "text": "product delivered is wrong"
    },
    {
      "value": 2,
      "text": "product is different from the description on the website or not as advertised"
    },
    {
      "value": 3,
      "text": "product arrives expired"
    },
    {
      "value": 4,
      "text": "branded product is unsealed"
    },
    {
      "value": 5,
      "text": "size or color is not a match"
    },
    {
      "value": 6,
      "text": "warranty documents are missing despite stating on the website"
    }
  ],
  "business_type": "b2b"
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Item not found with this qr code",
  "status_code": 404
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "You are scanning invalid product."
}
```
### Scan return item from customer.
___

* **URL :** `BASE_URL + partner/api/v1/return/scan`

* **Method :** `PUT`

* **URL Params :**

```json
{
  "return_id": 6097,
  "qr_code": "kitkat"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": "Successfully received.",
  "status_code": 200
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Wrong return order under this partner."
}
```
