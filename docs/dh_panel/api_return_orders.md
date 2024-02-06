**Return Order APIs**
___

* **URL :** `BASE_URL + /distributors/api/v1/return_orders`
* **Method :** `GET`

* **URL Params :**

`All params are optional here`

```json
{
  "start_date_time": "2022-01-01",
  "end_date_time": "2022-07-01",
  "order_id": 29756,
}
```

* **Success Response**
    * **Code :**`200`
    * **Content :**

```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched customer list",
  "data": [
    {
      "id": 835,
      "customer_order_number": null,
      "customer_id": 323,
      "customer_name": "Humayra Himiii",
      "shop_name": "Honda Seller Storeeee",
      "created_at": "2022-03-03T13:28:36.239+06:00",
      "phone": "01704587608",
      "price": "6003.0",
      "return_type": "Packed",
      "return_status": "Completed",
      "customer_order_type": "organic",
      "order_id": 4449,
      "initiated_by": "Partner"
    }
  ]
}
```

* **Error Response**
    * **Code :**`422`
    * **Content :**

```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch return orders",
  "data": {}
}
```

### Return Order Details

* **URL :** `BASE_URL + /distributors/api/v1/return_orders/:id`
* **Method :** `GET`
* **URL Params :**
* **Success Response**
* **Code :**`200`
* **Content :**

```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched return order details",
  "data": {
    "return_details": {
      "id": 835,
      "backend_id": "0000835",
      "order_id": "0004449",
      "order_backend_id": 4449,
      "date": "2022-03-03T13:28:36.239+06:00",
      "item_title": null,
      "price": null,
      "return_status": "Completed",
      "return_type": "Packed",
      "return_reason": "product is received in damaged/defective/incomplete condition",
      "description": "",
      "preferred_delivery_date": null,
      "form_of_return": "To Partner",
      "return_option": "return to partner",
      "return_option_value": 1,
      "payment_type": "Cash On Delivery",
      "total_discount_amount": "0.0",
      "is_customer_paid": false,
      "distributor_name": "Narsingdi Distributor"
    },
    "customer": {
      "id": 323,
      "name": "Humayra Himiii",
      "phone": "01624681829",
      "email": "humayra@misfit.tech"
    },
    "rider": {},
    "return_order_details": {
      "id": 4449,
      "sub_total": null,
      "total_discount": "0.0",
      "shipping_charge": "0.0",
      "vat_shipping_charge": "0.0",
      "total_price": "0.0",
      "warehouse_id": 8,
      "partner_details": {
        "id": 151,
        "name": "Honda Seller Storeeee",
        "phone": "01704587608",
        "district": "Narshingdi",
        "thana": "Kahalu",
        "area": "Khalishpur",
        "zip_code": null,
        "schedule": "sat_sun_mon_tues_wed_thurs"
      },
      "router_details": {
        "title": "prado router",
        "phone": "01749400945"
      },
      "items": [
        {
          "product_title": "Kitkat",
          "product_image": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/qpt7k6jmwo6i99n7c21t0q2356sj?response-content-disposition=attachment%3B%20filename%3D%22Network.webp%22%3B%20filename%2A%3DUTF-8%27%27Network.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220821%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220821T123715Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=e26e7403f1ab6efcf59036df6bd97e0e8595654ab02ad1a9f96aabde9337b7ff",
          "shopoth_line_item_id": 11197,
          "quantity": 3,
          "price": "2001.0",
          "discount_amount": "0.0",
          "sub_total": "6003.0",
          "total": "6003.0",
          "item": {
            "product_title": "Kitkat",
            "sku": "kitkat",
            "unit_price": "5000.0",
            "product_attribute_values": []
          }
        }
      ],
      "returned_items": []
    }
  }
}
```

* **Error Response**
    * **Example-1 :**
        * **Code :** `404`
        * **Content :**

```json
{
  "success": false,
  "status": 404,
  "message": "Return order not found",
  "data": {}
}
```

*
    * **Example-2 :**
    * **Code :** `422`
    * **Content :**

```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch customer order details",
  "data": {}
}
```

### Receive return orders from Rider/SR

* **URL :** `BASE_URL + /distributors/api/v1/return_orders/:id/receive`
* **Method :** `PUT`
* **URL Params :**
* **Success Response**
* **Code :**`200`
* **Content :**

```json
{
  "success": true,
  "status": 200,
  "message": "Return order received successfully.",
  "data": {}
}
```

* **Error Response**
* **Code :** `404`
* **Content :**

```json
{
  "success": false,
  "status": 404,
  "message": "Unable to receive return order.",
  "data": {}
}
```
