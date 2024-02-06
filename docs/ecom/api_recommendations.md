### Get similar products.
___

* **URL :** `BASE_URL + /shop/api/v1/recommendations/similar_products`
* **Method :** `GET`
* **URL Params :**

```json
{
  "product_slug": "cocacola-143-love",
  "warehouse_id": 8
}
```
* **Success Response**
 * **Code :**`201`
 * **Content :**
```json
{
  "success": true,
  "status": 201,
  "message": "Successfully fetched product recommendations",
  "data":[]
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Something went wrong due to #{error.message}",
   "data": {}
}
```
### Get similar picked products
___

* **URL :** `BASE_URL + /shop/api/v1/recommendations/bought_together`
* **Method :** `GET`
* **URL Params :**

```json
{
  "product_id": 3860,
  "warehouse_id": 8
}
```
* **Success Response**
 * **Code :**`201`
 * **Content :**
```json
{
  "success": true,
  "status_code": 200,
  "message": "Successfully fetched bought together product recommendations",
  "data": []
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Something went wrong due to #{error.message}",
   "data": {}
}
```
### Get recommendations for you
___

* **URL :** `BASE_URL + /shop/api/v1/recommendations/for_you`
* **Method :** `GET`
* **URL Params :**

```json
{
  "warehouse_id": 8
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success":true,
  "status_code":200,
  "message":"Successfully fetched recommendations for you",
  "data":[
    {
      "id":4002,
      "title":"Sun Chips update",
      "bn_title":"হ্যালো",
      "image_url":"http://cdn.shopoth.net/variants/t5f80ldsz144du0vc4f196hcquda/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099","view_url":"/products/details/4002","price":160,"discount":"0","discount_stringified":"0 %","effective_mrp":160,"brand_id":70,"brand_name":"fruits","brand_name_bn":"test1","variant_id":3176,"is_wishlisted":false,"badge":"0% EMI","bn_badge":"০% ইএমআই","slug":"sun-chips","sell_count":43,"max_quantity_per_order":null,"sku_type":"variable_product","root_category":{"id":18,"title":"Snack and Beveragess","bn_title":" নাস্তা এবং পানীয়","slug":"snack-and-beveragess"},"available_quantity":0,"is_available":false,"is_requested":false},{"id":4002,"title":"Sun Chips update","bn_title":"হ্যালো","image_url":"http://cdn.shopoth.net/variants/t5f80ldsz144du0vc4f196hcquda/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
      "view_url":"/products/details/4002",
      "price":160,
      "discount":"0",
      "discount_stringified":"0 %",
      "effective_mrp":160,
      "brand_id":70,
      "brand_name":"fruits",
      "brand_name_bn":"test1",
      "variant_id":3176,
      "is_wishlisted":false,
      "badge":"0% EMI",
      "bn_badge":"০% ইএমআই",
      "slug":"sun-chips",
      "sell_count":43,
      "max_quantity_per_order":null,
      "sku_type":"variable_product",
      "root_category":{
        "id":18,
        "title":"Snack and Beveragess",
        "bn_title":" নাস্তা এবং পানীয়",
        "slug":"snack-and-beveragess"
      },
      "available_quantity":0,
      "is_available":false,
      "is_requested":false
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
   "message": "Something went wrong due to #{error.message}",
   "data": {}
}
```
### Get product suggestions for brand
___

* **URL :** `BASE_URL + /shop/api/v1/recommendations/brand_products`
* **Method :** `GET`
* **URL Params :**

```json
{
  "brand_id": 51
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": true,
  "status_code": 200,
  "message": "Successfully fetched product recommendations",
  "data": [
    {
      "id": 3898,
      "title": "testing product details edit",
      "bn_title": "",
      "image_url": "http://cdn.shopoth.net/variants/y1rn5k4kmg6cbwxu6lyfc6kpmdsg/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
      "view_url": "/products/details/3898",
      "price": 3444,
      "discount": "0",
      "discount_stringified": "0 %",
      "effective_mrp": 3444,
      "brand_id": 51,
      "brand_name": "Local Brand New",
      "brand_name_bn": "Local Brand New",
      "variant_id": 3005,
      "is_wishlisted": false,
      "badge": "",
      "bn_badge": "",
      "slug": "testing-product-details-edit",
      "sell_count": 0,
      "max_quantity_per_order": null,
      "sku_type": "variable_product",
      "root_category": {
        "id": 387,
        "title": "hjgjgjgjghj",
        "bn_title": "fhgfhgfgfgfgf",
        "slug": "hjgjgjgjghj"
      },
      "available_quantity": 0,
      "is_available": false,
      "is_requested": false
    },
    {
      "id": 3897,
      "title": "p112",
      "bn_title": "",
      "image_url": "http://cdn.shopoth.net/variants/vcpsjwmuc0tq6xx51a5spkavbqze/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
      "view_url": "/products/details/3897",
      "price": 122,
      "discount": "0",
      "discount_stringified": "0 %",
      "effective_mrp": 122,
      "brand_id": 51,
      "brand_name": "Local Brand New",
      "brand_name_bn": "Local Brand New",
      "variant_id": 3004,
      "is_wishlisted": false,
      "badge": "",
      "bn_badge": "",
      "slug": "p112",
      "sell_count": 0,
      "max_quantity_per_order": null,
      "sku_type": "variable_product",
      "root_category": {
        "id": 390,
        "title": "asd33",
        "bn_title": "hddj",
        "slug": "asd5"
      },
      "available_quantity": 0,
      "is_available": false,
      "is_requested": false
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
   "message": "Something went wrong due to #{error.message}",
   "data": {}
}
```
### Get product suggestions for user_preference.
___

* **URL :** `BASE_URL + /shop/api/v1/recommendations/user_preference`
* **Method :** `GET`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`201`
* **Content :**
```json
{
  "success": true,
  "status": 201,
  "message": "Successfully fetched product recommendations",
  "data":[]
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Something went wrong due to #{error.message}",
   "data": {}
}
```
### Get product suggestions for own brand.
___

* **URL :** `BASE_URL + /shop/api/v1/recommendations/own_brand_products`
* **Method :** `GET`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`201`
* **Content :**
```json
{
  "success": true,
  "status": 201,
  "message": "Successfully fetched product recommendations",
  "data":[]
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Something went wrong due to #{error.message}",
   "data": {}
}
```