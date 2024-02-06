### Get Return Customer Order list.
___

* **URL :** `BASE_URL + /shop/api/v1/return_customer_orders/lists`
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
    "return_order_id": 1002,
    "order_id": 5838,
    "ordered_on": "2022-10-31T19:23:15.385+06:00",
    "requested_at": "2022-10-31T19:51:13.339+06:00",
    "status": "initiated",
    "bn_status": "",
    "initiated_by": "User",
    "total": "4250.0",
    "method": "From home"
  },
  {
    "return_order_id": 1001,
    "order_id": 5839,
    "ordered_on": "2022-10-31T19:23:43.305+06:00",
    "requested_at": "2022-10-31T19:50:56.806+06:00",
    "status": "in_transit",
    "bn_status": "",
    "initiated_by": "User",
    "total": "200.0",
    "method": "From home"
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
   "message": "Can not fetch due to #{error.message}",
   "data": {}
}
```
### Get Return Customer Order details.
___

* **URL :** `BASE_URL + /shop/api/v1/return_customer_orders/:id`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully fetched return customer order details.",
  "data":
  {
    "id":598,
    "frontend_id":"0000598",
    "sub_total":"4250.0",
    "refundable_amount":"4204.0",
    "pick_up_charge":"40.0",
    "vat_shipping_charge":"6.0",
    "refunded":false,
    "customer_order_id":5838,
    "created_at":"2022-10-31T19:51:13.334+06:00",
    "reschedule_date":null,
    "return_count":1,
    "order_status":"Delivered",
    "bn_order_status":"ডেলিভারী করা হয়েছে",
    "form_of_return":"from_home",
    "return_method":"Home Picked Up",
    "note":"Rider will collect from your given address",
    "partner":{},
    "return_address":{
    "id":3057,
      "address_title":"others",
      "name":"shopoth user",
      "bn_name":null,
      "phone":"0185xxxxxx",
      "district_id":1,
      "thana_id":13,
      "area_id":4,
      "district_name":"Narshingdi",
      "district_bn_name":"Narshingdi",
      "thana_name":"Bogra",
      "thana_bn_name":"BN Bogra",
      "area_name":"Noapara",
      "area_bn_name":"নওয়াপাড়া",
      "address_line":"avc",
      "bn_address_line":null,
      "zip_code":null
    },
    "return_ids":["0001002"],
    "return_items":[
      {
        "return_id":1002,
        "backend_id":"0001002",
        "customer_order_id":5838,
        "shopoth_line_item_id":14872,
        "description":"",
        "return_status":"Initiated",
        "bn_return_status":"Initiated",
        "created_at":"2022-10-31T19:51:13.339+06:00",
        "reason":"warranty documents are missing despite stating on the website",
        "return_images":[],
        "items":{
          "title":"Kitkat",
          "bn_title":"কিটকেট",
          "slug":"শীর্ষ-খবর",
          "quantity":1,
          "variant_id":2954,
          "amount":"4250.0",
          "product_attribute":[],
          "hero_image":"http://cdn.shopoth.net/wzsq3qjcfhfog8ux4isks4dgq5y0"
        }
      }
    ]
  }
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch Return Customer Order details",
   "data": {}
}
```
### Create Return Customer Order
___

* **URL :** `BASE_URL + /shop/api/v1/return_customer_orders`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "shopoth_line_item_id": 2345,
  "customer_order_id": 723,
  "reason": "Color is not right"
}
```
* **Success Response**
 * **Code :**`201`
 * **Content :**
```json
{
  "success":true,
  "status":201,
  "message":"Return is initiated successfully.",
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
   "message": "This can not be refunded",
   "data": {}
}
```
