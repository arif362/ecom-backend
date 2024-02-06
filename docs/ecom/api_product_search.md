### Product Search.
___

* **URL :** `BASE_URL + /shop/api/v1/product/search`
* **Method :** `GET`
* **URL Params :**

```json
{
  "message": "Shopoth User Message",
  "rating": 2
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully fetched searched products.",
  "data":[
    {
      "id":3860,
      "title":"Kitkat",
      "bn_title":"কিটকেট",
      "image_url":"http://cdn.shopoth.net/variants/wzsq3qjcfhfog8ux4isks4dgq5y0/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
      "view_url":"/products/details/3860",
      "price":5000,
      "discount":"150.0",
      "discount_stringified":"150 Tk",
      "effective_mrp":4850,
      "brand_id":51,
      "brand_name":"Local Brand New",
      "brand_name_bn":"Local Brand New",
      "variant_id":2954,
      "is_wishlisted":false,
      "badge":"150 Tk Discount",
      "bn_badge":"১৫০ টাকা ছাড়",
      "slug":"শীর্ষ-খবর",
      "sell_count":420,
      "max_quantity_per_order":null,
      "sku_type":"simple_product",
      "root_category":{
        "id":178,
        "title":"Lifestyle",
        "bn_title":"লাইফস্টাইল",
        "slug":"lifestyle-product"
      },
      "available_quantity":8580,
      "is_available":true,
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
   "message": "Unable to fetch searched products.",
   "data": {}
}
```
### Get all advance filter for a search key
___

* **URL :** `BASE_URL + /shop/api/v1/product/advance_filter`
* **Method :** `GET`
* **URL Params :**

```json
{
  "keyword": "kitkat"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched advance filter list.",
  "data": {
    "brands": [
      {
        "id": 51,
        "name": "Local Brand New",
        "bn_name": "Local Brand New",
        "logo": "http://cdn.shopoth.net/g90eohi47rsqpsc65mgn5h2p6qpj",
        "is_own_brand": true,
        "slug": "local-brand-new",
        "public_visibility": true,
        "homepage_visibility": false,
        "is_followed": false,
        "redirect_url": "http://shopoth.shop/tesla/products?categories=health-care"
      }
    ],
    "price_range": {
      "min_price": "4850.0",
      "max_price": "4850.0"
    },
    "filter_attributes": []
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
   "message": "Unable to fetch advance filter list.",
   "data": {}
}
```
### Get filtered products of a specific product type
___

* **URL :** `BASE_URL + /shop/api/v1/product/filter`
* **Method :** `GET`
* **URL Params :**

```json
{
  "product_type": "best-selling"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Product fetched successfully.",
  "data":[
    {
      "id":3860,
      "title":"Kitkat",
      "bn_title":"কিটকেট",
      "image_url":"http://cdn.shopoth.net/variants/wzsq3qjcfhfog8ux4isks4dgq5y0/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
      "view_url":"/products/details/3860",
      "price":5000,
      "discount":"150.0",
      "discount_stringified":"150 Tk",
      "effective_mrp":4850,
      "brand_id":51,
      "brand_name":"Local Brand New",
      "brand_name_bn":"Local Brand New",
      "variant_id":2954,
      "is_wishlisted":false,
      "badge":"150 Tk Discount",
      "bn_badge":"১৫০ টাকা ছাড়",
      "slug":"শীর্ষ-খবর",
      "sell_count":420,
      "max_quantity_per_order":null,
      "sku_type":"simple_product",
      "available_quantity":8580,
      "is_available":true,
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
   "message": "Unable to filter products",
   "data": {}
}
```
### Get advanced filter options for a specific product type's products
___

* **URL :** `BASE_URL + /shop/api/v1/product/filter_options`
* **Method :** `GET`
* **URL Params :**

```json
{
  "product_type": "best-selling"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched advance filter list.",
  "data": {
    "brands": [
      {
        "id": 55,
        "name": "Cameron Williamson",
        "bn_name": "asdasd",
        "logo": "http://cdn.shopoth.net/variants/7ec9za9qqfyrew75rwvhxb6kufkp/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
        "is_own_brand": true,
        "slug": "cameron-williamson",
        "public_visibility": false,
        "homepage_visibility": false,
        "is_followed": false,
        "redirect_url": null
      },
      {
        "id": 24,
        "name": "Mac",
        "bn_name": "Mac",
        "logo": "http://cdn.shopoth.net/variants/bmu09q7amy8j8knu4tqgpu7vh3jm/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
        "is_own_brand": true,
        "slug": "mac",
        "public_visibility": true,
        "homepage_visibility": false,
        "is_followed": false,
        "redirect_url": "https://www.youtube.com/watch?v=ujNpeo_kNNE"
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
   "message": "Unable to fetch advance filter list",
   "data": {}
}
```
