## **Partners APIs** ##
----

## ***Add bKash Number to Partner profile***

* **URL:** `BASE_URL + partner/api/v1/add_bkash_number
* **Method:** `PUT`
* **URL Params:**
```
params do
  requires :bkash_number, type: String
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "bkash number added successfully",
  "data": {}
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**
         ```json 
          {"message": "", "status_code": ...}
         ```

  * **if bkash number already taken:**
    ```json 
    {
     "message": "bkash number has already been taken",
     "status_code": 403
    }
    ```
  * **for other error:**
    ```json
    {
    "status_code": 422,
    "message": "Unable to add bKash number"
    }
    ```
----

### Partner / Retailer Assistant login
___

* **URL :** `BASE_URL + partner/api/v1/login`
* **Method :** `POST`
* **URL Params :**

```json
{
    "phone": "017xxxxxxxx",
    "password": "xxxxxx"
}
```
* **Success Response** For Partner
* **Code :**`200`
* **Content :**
```json
{
  "type": "partner",
  "auth_token": "auth_token",
  "partner_name": "#{partner.name}",
  "partner_code": "#{partner.partner_code}",
  "retailer_code": "#{partner.retailer_code}",
  "bkash_number": "#{partner.bkash_number}",
  "business_type": "b2c"
}
```
* **Success Response** For Retailer Assistant
* **Code :**`200`
* **Content :**
```json
{
  "type": "ra",
  "auth_token": "auth_token"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "error": "Invalid phone or password."
}
```
### Partner Balance
___

* **URL :** `BASE_URL + partner/api/v1/balance`
* **Method :** `POST`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "balance": 1230
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "error": "Partner not present"
}
```
### Partner settings
___

* **URL :** `BASE_URL + partner/api/v1/settings`
* **Method :** `POST`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "phone": "017xxxxxxxx",
  "balance": 1230
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "error": "Partner not present"
}
```
### Fetch Order Received History
___

* **URL :** `BASE_URL + partner/api/v1/order_received_history`
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
    "date": null,
    "order_list": [
      {
        "order_id": 5883,
        "customer_name": "Shopoth User",
        "order_type": "organic",
        "business_type": "b2c",
        "app_order_type": "organic",
        "phone": "0162xxxxxxxx",
        "amount": "4250.0",
        "area": null
      },
      {
        "order_id": 5972,
        "customer_name": "Honda Seller Storeeee",
        "order_type": "induced",
        "business_type": "b2b",
        "app_order_type": "induced",
        "phone": "0162xxxxxxx",
        "amount": "800.0",
        "area": "th-3 area-1"
      }
    ]
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to fetch order received history",
  "status_code": 404
}
```
### Fetch Order Delivered History
___

* **URL :** `BASE_URL + partner/api/v1/order_delivered_history`
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
    "date": "20/09/2022",
    "order_list": [
      {
        "order_id": 5696,
        "customer_name": null,
        "order_type": "organic",
        "business_type": "b2c",
        "app_order_type": "organic",
        "phone": null,
        "amount": "8769.0",
        "area": null
      }
    ]
  },
  {
    "date": "31/08/2022",
    "order_list": [
      {
        "order_id": 5578,
        "customer_name": "beautiful day ",
        "order_type": "organic",
        "business_type": "b2c",
        "app_order_type": "organic",
        "phone": "017xxxxxxx",
        "amount": "4884.0",
        "area": null
      }
    ]
  },
  {
    "date": "08/11/2022",
    "order_list": [
      {
        "order_id": 5878,
        "customer_name": "Shopoth User",
        "order_type": "organic",
        "business_type": "b2c",
        "app_order_type": "organic",
        "phone": "016xxxxxxxx",
        "amount": "4450.0",
        "area": null
      }
    ]
  },
  {
    "date": "12/10/2022",
    "order_list": [
      {
        "order_id": 5803,
        "customer_name": "Shopoth User",
        "order_type": "organic",
        "business_type": "b2c",
        "app_order_type": "organic",
        "phone": "016xxxxxxxxx",
        "amount": "12750.0",
        "area": null
      }
    ]
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to fetch order delivered history",
  "status_code": 404
}
```
### Fetch Order Payment History.
___

* **URL :** `BASE_URL + partner/api/v1/payment_history`
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
    "date": "13/12/2022",
    "order_list": [
      {
        "order_id": 5971,
        "customer_name": "Honda Seller Storeeee",
        "order_type": "induced",
        "business_type": "b2b",
        "app_order_type": "induced",
        "phone": "0162xxxxxxx",
        "amount": "44950.0",
        "area": "th-3 area-1"
      }
    ]
  },
  {
    "date": "08/12/2022",
    "order_list": [
      {
        "order_id": 6027,
        "customer_name": "Honda Seller Storeeee",
        "order_type": "induced",
        "business_type": "b2b",
        "app_order_type": "induced",
        "phone": "016xxxxxxx",
        "amount": "263.0",
        "area": "th-3 area-1"
      }
    ]
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to fetch payment history",
  "status_code": 404
}
```
### Fetch Order Return History.
___

* **URL :** `BASE_URL + partner/api/v1/order_return_history`
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
    "date": "03/03/2022",
    "order_list": [
      {
        "order_id": 834,
        "customer_name": "shopoth user",
        "order_type": "induced",
        "business_type": "b2c",
        "app_order_type": "induced",
        "phone": "016xxxxxxx",
        "amount": "14002.0",
        "area": "th-3 area-1"
      }
    ]
  },
  {
    "date": "24/11/2022",
    "order_list": [
      {
        "order_id": 1059,
        "customer_name": "Shopoth User",
        "order_type": "induced",
        "business_type": "b2c",
        "app_order_type": "induced",
        "phone": "016xxxxxxxx",
        "amount": "5034.0",
        "area": "th-3 area-1"
      }
    ]
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to fetch return history",
  "status_code": 404
}
```
### Customer Order Parcel List
___

* **URL :** `BASE_URL + partner/api/v1/parcel`
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
    "order_id": 4309,
    "customer": {
      "customer_id": 323,
      "name": "Shopoth User",
      "phone": "0162xxxxxxx"
    },
    "amount": "2000.0",
    "order_type": "organic",
    "business_type": "b2c",
    "app_order_type": "organic",
    "status": "completed",
    "app_status": "completed",
    "order_place_at": "1644902880592",
    "expected_delivery_time": "1645162080592",
    "expire_date": "1645682721501",
    "expected_delivery_time_exceed": true
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to find parcel list",
  "status_code": 404
}
```
### Return Pending Payment List
___

* **URL :** `BASE_URL + partner/api/v1/payments/pending`
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
    "order_id": 4309,
    "customer": {
      "name": "Shopoth User",
      "phone": "0162xxxxxxxx"
    },
    "amount": "2000.0",
    "order_type": "organic",
    "business_type": "b2c",
    "app_order_type": "organic",
    "payment_type": "cash_on_delivery",
    "app_pay_type": "cash_on_delivery",
    "pay_status": "customer_paid",
    "app_pay_status": "customer_paid",
    "status": "completed",
    "app_status": "completed",
    "wallet_payment": "0.0"
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to fetch Payment",
  "status_code": 404
}
```
### Order Details
___

* **URL :** `BASE_URL + partner/api/v1/:order_id/history/order_details`
* **Method :** `GET`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "order_id": 4309,
  "order_date": "2022-02-15T11:28:00.592+06:00",
  "customer": {
    "name": "Shopoth User",
    "phone": "0162xxxxxx"
  },
  "order_type": "organic",
  "order_status": "completed",
  "shopoth_line_items": [
    {
      "line_item_id": 10832,
      "item": {
        "product_title": "Kitkat",
        "product_attribute_values": []
      },
      "quantity": 1,
      "price": {
        "retailer_price": "4850.0",
        "consumer_price": "2000.0",
        "partner_margin": "150.0"
      }
    }
  ],
  "total_price": {
    "consumer_price": "2000.0"
  },
  "vat_shipping_charge": "0.0",
  "business_type": "b2c"
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to fetch customer order details",
  "status_code": 404
}
```
### Order Details
___

* **URL :** `BASE_URL + partner/api/v1/:order_id/history/order_details`
* **Method :** `GET`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "order_id": 4309,
  "order_date": "2022-02-15T11:28:00.592+06:00",
  "customer": {
    "name": "Shopoth User",
    "phone": "0162xxxxxx"
  },
  "order_type": "organic",
  "order_status": "completed",
  "shopoth_line_items": [
    {
      "line_item_id": 10832,
      "item": {
        "product_title": "Kitkat",
        "product_attribute_values": []
      },
      "quantity": 1,
      "price": {
        "retailer_price": "4850.0",
        "consumer_price": "2000.0",
        "partner_margin": "150.0"
      }
    }
  ],
  "total_price": {
    "consumer_price": "2000.0"
  },
  "vat_shipping_charge": "0.0",
  "business_type": "b2c"
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to fetch customer order details",
  "status_code": 404
}
```
### Get SR phone number
___

* **URL :** `BASE_URL + partner/api/v1/sr_phone`
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
  "sr_phone": "0174xxxxxx"
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to get SR phone",
  "status_code": 404
}
```
### Deliver Order to Customer
___

* **URL :** `BASE_URL + partner/api/v1/deliver_to_customer`
* **Method :** `POST`
* **URL Params :**

```json
{
  "order_id": 1234,
  "customer_pin": "5431"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": "Successfully delivered.",
  "status_code": 200
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
  "message": "Invalid pin given.",
  "status_code": 403
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "You are not allowed to delivered this order.",
  "status_code": 404
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Unable to deliver order to customer",
  "status_code": 404
}
```
### Scan Invoice/Collect order
___

* **URL :** `BASE_URL + partner/api/v1/collect_order`
* **Method :** `PUT`
* **URL Params :**

```json
{
  "invoice_id": "1234"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "message": "Order received successfully"
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": false,
  "message": "Can't receive order"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "success": false,
  "message": "Can't receive order"
}
```
### Partner's product search
___

* **URL :** `BASE_URL + partner/api/v1/product_search`
* **Method :** `GET`
* **URL Params :**

```json
{
  "search_key": "hero"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "product_id": 3937,
    "title": "",
    "description": "",
    "short_description": "",
    "warranty_period": "",
    "warranty_policy": "",
    "video_url": "",
    "warranty_type": "no_warranty",
    "warranty_period_type": null,
    "company": "",
    "brand": "Prado Brand",
    "certification": "",
    "license_required": "",
    "material": "",
    "consumption_guidelines": "",
    "temperature_requirement": "",
    "keywords": "",
    "brand_message": null,
    "tagline": "",
    "hero_image": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/8eb8j3cftlfpl7cc8ny88wxnbdhj?response-content-disposition=inline%3B%20filename%3D%22hero-bikes.jpg%22%3B%20filename%2A%3DUTF-8%27%27hero-bikes.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221226%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20221226T101029Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=dd48e8bffb5ca2551079ff158b26bb62c8b5a603743edff712e13fde012e3964",
    "images": null,
    "product_attribute_values": [
      {
        "product_attribute_name": "color",
        "product_attribute_values": [
          {
            "id": 24,
            "value": "Yellow",
            "images": null
          },
          {
            "id": 118,
            "value": "red",
            "images": null
          },
          {
            "id": 116,
            "value": "green",
            "images": null
          }
        ]
      },
      {
        "product_attribute_name": "Size",
        "product_attribute_values": [
          {
            "id": 51,
            "value": "M",
            "images": null
          },
          {
            "id": 53,
            "value": "L",
            "images": null
          }
        ]
      }
    ],
    "variants": [
      {
        "id": 3080,
        "sku": "heroym",
        "price_consumer": 5000,
        "price_discounted": 5000,
        "price_retailer": 5000,
        "sku_case_dimension": "",
        "consumer_discount": "0.0",
        "available_quantity": 2502,
        "product_attribute_values": [
          {
            "id": 24,
            "value": "Yellow",
            "product_attribute_id": 36,
            "product_attribute_name": "color"
          },
          {
            "id": 51,
            "value": "M",
            "product_attribute_id": 19,
            "product_attribute_name": "Size"
          }
        ]
      },
      {
        "id": 3081,
        "sku": "herorm",
        "price_consumer": 200,
        "price_discounted": 200,
        "price_retailer": 200,
        "sku_case_dimension": "",
        "consumer_discount": "0.0",
        "available_quantity": 2351,
        "product_attribute_values": [
          {
            "id": 118,
            "value": "red",
            "product_attribute_id": 36,
            "product_attribute_name": "color"
          },
          {
            "id": 51,
            "value": "M",
            "product_attribute_id": 19,
            "product_attribute_name": "Size"
          }
        ]
      },
      {
        "id": 3082,
        "sku": "herogm",
        "price_consumer": 5001,
        "price_discounted": 5001,
        "price_retailer": 5001,
        "sku_case_dimension": "",
        "consumer_discount": "0.0",
        "available_quantity": 2319,
        "product_attribute_values": [
          {
            "id": 116,
            "value": "green",
            "product_attribute_id": 36,
            "product_attribute_name": "color"
          },
          {
            "id": 51,
            "value": "M",
            "product_attribute_id": 19,
            "product_attribute_name": "Size"
          }
        ]
      },
      {
        "id": 3084,
        "sku": "herorl",
        "price_consumer": 7000,
        "price_discounted": 7000,
        "price_retailer": 7000,
        "sku_case_dimension": "",
        "consumer_discount": "0.0",
        "available_quantity": 2093,
        "product_attribute_values": [
          {
            "id": 118,
            "value": "red",
            "product_attribute_id": 36,
            "product_attribute_name": "color"
          },
          {
            "id": 53,
            "value": "L",
            "product_attribute_id": 19,
            "product_attribute_name": "Size"
          }
        ]
      },
      {
        "id": 3085,
        "sku": "herogl",
        "price_consumer": 6000,
        "price_discounted": 6000,
        "price_retailer": 6000,
        "sku_case_dimension": "",
        "consumer_discount": "0.0",
        "available_quantity": 2099,
        "product_attribute_values": [
          {
            "id": 116,
            "value": "green",
            "product_attribute_id": 36,
            "product_attribute_name": "color"
          },
          {
            "id": 53,
            "value": "L",
            "product_attribute_id": 19,
            "product_attribute_name": "Size"
          }
        ]
      },
      {
        "id": 3083,
        "sku": "heroyl",
        "price_consumer": 6000,
        "price_discounted": 6000,
        "price_retailer": 6000,
        "sku_case_dimension": "",
        "consumer_discount": "0.0",
        "available_quantity": 2271,
        "product_attribute_values": [
          {
            "id": 24,
            "value": "Yellow",
            "product_attribute_id": 36,
            "product_attribute_name": "color"
          },
          {
            "id": 53,
            "value": "L",
            "product_attribute_id": 19,
            "product_attribute_name": "Size"
          }
        ]
      }
    ]
  },
  {
    "product_id": 3991,
    "title": "",
    "description": "",
    "short_description": "",
    "warranty_period": "",
    "warranty_policy": "",
    "video_url": "",
    "warranty_type": "no_warranty",
    "warranty_period_type": null,
    "company": "",
    "brand": "Prado Brand",
    "certification": "",
    "license_required": "",
    "material": "",
    "consumption_guidelines": "",
    "temperature_requirement": "",
    "keywords": "",
    "brand_message": null,
    "tagline": "",
    "hero_image": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/nevb7w1js61u8oxjgrk6wc0l695e?response-content-disposition=inline%3B%20filename%3D%22bike-price.png%22%3B%20filename%2A%3DUTF-8%27%27bike-price.png&response-content-type=image%2Fpng&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221226%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20221226T101029Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=046e4879eec69549469c513deef6b28819c8fb243663885e1bfdef22b14c214d",
    "images": null,
    "product_attribute_values": [],
    "variants": [
      {
        "id": 3161,
        "sku": "heroymylrm",
        "price_consumer": 10000,
        "price_discounted": 10000,
        "price_retailer": 10000,
        "sku_case_dimension": "",
        "consumer_discount": "0.0",
        "available_quantity": 1,
        "product_attribute_values": []
      }
    ]
  }
]
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": false,
  "message": "No product found"
}
```
### Partner's product search
___

* **URL :** `BASE_URL + partner/api/v1/receive_margin`
* **Method :** `POST`
* **URL Params :**

```json
{
  "month": 3,
  "year": 2022
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": "Profit collected successfully.",
  "status_code": 200
}

```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "SR has not received payment for this month",
  "status_code": 422
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Payment already exists",
  "status_code": 422
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to receive profit margin",
  "status_code": 422
}
```
### Partner list for a retailer assistant
___

* **URL :** `BASE_URL + partner/api/v1/list`
* **Method :** `POST`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id": 177,
    "name": "ABC Partner",
    "phone": "0162xxxxxx",
    "partner_code": "ABCP1",
    "retailer_code": null
  },
  {
    "id": 176,
    "name": "afzal store",
    "phone": "0172xxxxxx",
    "partner_code": "S07V022200",
    "retailer_code": null
  }
]
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to fetch partners due to: #{error.message}",
  "status_code": 422
}
```
