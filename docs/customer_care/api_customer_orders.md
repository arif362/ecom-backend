### Show all orders of all customers
___
* **URL :** `BASE_URL + customer_care/api/v1/customer_orders`
* **Method :** `GET`
* * **Header :** `Auth-token`
* **URL Params :**

```json
{
  "start_date_time": "2022-11-28",
  "end_date_time": "2022-12-27"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "order_id":6173,
    "order_no":"0006173",
    "customer_id":151,
    "customer_name":"Sumon",
    "mobile":"0172xxxxxxx",
    "location":"th-3 area-1",
    "order_type":"induced",
    "shipping_type":"Pick Up Point",
    "pay_type":"cash_on_delivery",
    "status":"Order placed",
    "preferred_delivery_date":null,
    "total_amount":"24000.0",
    "date":"2022-12-26T10:43:48.727+06:00"
  },
  {
    "order_id":6172,
    "order_no":"0006172",
    "customer_id":726,
    "customer_name":"Imam Hossain Rashed",
    "mobile":"01833xxxxx",
    "location":"th-3 area-1",
    "order_type":"induced",
    "shipping_type":"Pick Up Point",
    "pay_type":"cash_on_delivery",
    "status":"Order placed",
    "preferred_delivery_date":null,
    "total_amount":"453.0",
    "date":"2022-12-22T12:08:03.872+06:00"
  }
]
 ```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": false,
  "message": "Customer orders not found"
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
### Get details of specific customer order for customer care agent
___
* **URL :** `BASE_URL + customer_care/api/v1/customer_orders/details/:id`
* **Method :** `GET`
* * **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "order_id":6168,
  "order_no":"0006168",
  "status":"Order placed",
  "status_key":"order_placed",
  "cancellation_reason":null,
  "order_at":"2022-12-22T11:12:50.409+06:00",
  "preferred_delivery_date":null,
  "customer":
  {
    "id":517,
    "customer_type":"User",
    "name":"Hum",
    "phone":"0162xxxxxx",
    "email":null
  },
  "shipping_type":"Pick up point",
  "shipping_type_id":2,
  "partner":
  {
    "id":178,
    "name":"Honda Seller Storeeee",
    "phone":"0162xxxxxxx",
    "email":"ham_c@misfit.tech",
    "route_id":106,
    "area_name":"th-3 area-1",
    "area_id":22,
    "thana_id":3,
    "thana":"Kahalu",
    "district_id":1,
    "district":"Narshingdi",
    "section":"D"
  },
  "pay_type":"Nagad payment",
  "warehouse":
  {
    "name":"Narshingdi",
    "phone":"0167xxxxxxx",
    "email":"sajjad@misfit.tech",
    "route_id":"distribution"
  },
  "route":
  {
    "title":"IT-N-303",
    "phone":"017xxxxxx"
  },
  "rider":{},
  "ShippingAddress":{},
  "BillingAddress":{},
  "order_type":"organic",
  "sub_total":"190.0",
  "shipping_charge":"0.0",
  "vat_shipping_charge":"0.0",
  "total_discount_amount":"0.0",
  "grand_total":"190.0",
  "shopoth_line_items":
  [
    {
      "shopoth_line_item_id": 15439,
      "quantity": 1,
      "amount": "200.0",
      "item": {
        "product_title": "Sun Chips update",
        "sku": "TOMATOTANGO-30G",
        "unit_price": "200.0",
        "product_discount": "10.0",
        "product_attribute_values": [
          {
            "id": 257,
            "product_attribute_id": 76,
            "name": "Flavours",
            "value": "Tomato Tango",
            "bn_name": "Flavours",
            "bn_value": "TTere",
            "created_at": "2022-07-18T11:30:27.075+06:00",
            "updated_at": "2022-10-26T12:39:00.235+06:00",
            "is_deleted": false
          }
        ],
        "returned_order_items": [],
        "order_tracking": [],
        "is_customer_paid": true,
        "receiver_info": {
          "name": "himi",
          "phone": "01624681821"
        },
        "is_returnable": false,
        "cancellable": true,
        "distributor_id": 1,
        "distributor_name": "Narsingdi Distributor",
        "business_type": "b2c"
      }
    }
  ]
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
### Get details of specific customer order for customer care agent
___
* **URL :** `BASE_URL + customer_care/api/v1/customer_orders/shipping_types`
* **Method :** `GET`
* * **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "home_delivery":0,
  "express_delivery":1,
  "pick_up_point":2
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
