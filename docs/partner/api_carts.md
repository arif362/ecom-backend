### Count items of a cart
___

* **URL :** `BASE_URL + partner/api/v1/carts/items`

* **Method :** `GET`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "items": 2
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
   "status_code": 404,
   "message": "Unable to count line items"
}
```
### Get all shopoth_line_item in cart.
___

* **URL :** `BASE_URL + partner/api/v1/carts/details`

* **Method :** `GET`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "cart_id": 11054,
  "cart_sub_total": 2580,
  "cart_total_items": 11,
  "cart_discount": 0,
  "cart_total_price": 2580,
  "min_cart_value": 180,
  "shipping_charge": 0,
  "shopoth_line_items": [
    {
      "shopoth_line_item_id": 15450,
      "quantity": 4,
      "price": 301,
      "total_price": 1204,
      "discount_amount": 24,
      "consumer_price": 301,
      "sub_total": 1180,
      "variant_id": 2754,
      "product_id": 3728,
      "product_title": "Simple inventory2  (simple inventory2)",
      "product_image": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/ohoshjfop9xt5o3hpms8l0eumcxe?response-content-disposition=inline%3B%20filename%3D%22clothing.jpg%22%3B%20filename%2A%3DUTF-8%27%27clothing.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221226%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20221226T051020Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=f806325c281cf3d666ef76ce1881e47e878be331d4dfdb011e969a1a35095186",
      "max_quantity_per_order": 0,
      "is_available": true
    },
    {
      "shopoth_line_item_id": 15449,
      "quantity": 7,
      "price": 251,
      "total_price": 1757,
      "discount_amount": 357,
      "consumer_price": 251,
      "sub_total": 1400,
      "variant_id": 2016,
      "product_id": 2866,
      "product_title": "Pringles  (738847)",
      "product_image": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/jh66xnh3ujcf3cdlz5jrrvgas5oo?response-content-disposition=inline%3B%20filename%3D%2241stu1Wr-EL.jpg%22%3B%20filename%2A%3DUTF-8%27%2741stu1Wr-EL.jpg&response-content-type=image%2Fjpeg&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221226%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20221226T051020Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=644bedd99c4aed142f5c246fbb95c2d971eab5c93ac04d5ad0118500318d2650",
      "max_quantity_per_order": 7,
      "is_available": true
    }
  ]
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Unable to show cart details"
}
```
### create a cart and populate with shopoth_line_items
___

* **URL :** `BASE_URL + partner/api/v1/carts`

* **Method :** `POST`

* **URL Params :**

```json
{
    "variant_id": 2954,
    "quantity": 3
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "shopoth_line_item_id": 15452,
  "variant_id": 2954,
  "quantity": 3,
  "unit_price": 5000,
  "cart_id": 11054,
  "discount_amount": 450,
  "sub_total": 14550,
  "sample_for": null,
  "cart_info": {
    "cart_total_items": 14,
    "cart_sub_total": 17130,
    "cart_discount": 0,
    "cart_total_discount": 0,
    "cart_total_price": 17130
  },
  "total_items": 3
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Required product quantity not available"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Can not exceed products maximum order limit."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Cannot create cart"
}
```
### Delete Cart/Empty Cart
___

* **URL :** `BASE_URL + partner/api/v1/carts`

* **Method :** `DELETE`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": "Successfully deleted",
  "status_code_code": 200
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Partner has no cart"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Unable to delete cart"
}
```
### Add by one quantity
___

* **URL :** `BASE_URL + partner/api/v1/carts/shopoth_line_items/:shopoth_line_item_id/add-one`

* **Method :** `PUT`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "shopoth_line_item_id": 15452,
  "variant_id": 2954,
  "quantity": 4,
  "unit_price": 5000,
  "cart_id": 11054,
  "discount_amount": 600,
  "sub_total": 19400,
  "sample_for": null,
  "cart_info": {
    "cart_total_items": 15,
    "cart_sub_total": 21980,
    "cart_discount": 0,
    "cart_total_discount": 0,
    "cart_total_price": 21980
  },
  "total_items": 3
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Requested quantity is not available for placing order."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Unable to increase quantity"
}
```
### Add by one quantity
___

* **URL :** `BASE_URL + partner/api/v1/carts/shopoth_line_items/:shopoth_line_item_id/add-one`

* **Method :** `PUT`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "shopoth_line_item_id": 15452,
  "variant_id": 2954,
  "quantity": 4,
  "unit_price": 5000,
  "cart_id": 11054,
  "discount_amount": 600,
  "sub_total": 19400,
  "sample_for": null,
  "cart_info": {
    "cart_total_items": 15,
    "cart_sub_total": 21980,
    "cart_discount": 0,
    "cart_total_discount": 0,
    "cart_total_price": 21980
  },
  "total_items": 3
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Requested quantity is not available for placing order."
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Unable to increase quantity"
}
```
### Decrease by one quantity
___

* **URL :** `BASE_URL + partner/api/v1/carts/shopoth_line_items/:shopoth_line_item_id/dec-one`

* **Method :** `PUT`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "shopoth_line_item_id": 15452,
  "variant_id": 2954,
  "quantity": 3,
  "unit_price": 5000,
  "cart_id": 11054,
  "discount_amount": 450,
  "sub_total": 14550,
  "sample_for": null,
  "cart_info": {
    "cart_total_items": 14,
    "cart_sub_total": 17130,
    "cart_discount": 0,
    "cart_total_discount": 0,
    "cart_total_price": 17130
  },
  "total_items": 3
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Must keep one product"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Unable to decrease quantity"
}
```
### Remove item from a cart.
___

* **URL :** `BASE_URL + partner/api/v1/carts/shopoth_line_items/:shopoth_line_item_id/dec-one`

* **Method :** `DELETE`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "cart_info": {
    "cart_total_items": 11,
    "cart_sub_total": 2580,
    "cart_discount": 0,
    "cart_total_discount": 0,
    "cart_total_price": 2580
  },
  "total_items": 2
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "status_code": 422,
   "message": "Unable to remove product"
}
```
