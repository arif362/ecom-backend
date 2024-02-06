### Search products
___

* **URL :** `BASE_URL + /shop/api/v1/search/products/:keyword`
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
  "success": true,
  "status": 200,
  "message": "Successfully fetched searched products.",
  "data": [
    {
      "id": 3860,
      "title": "Kitkat",
      "bn_title": "কিটকেট",
      "image_url": "http://cdn.shopoth.net/variants/wzsq3qjcfhfog8ux4isks4dgq5y0/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
      "view_url": "/products/details/3860",
      "price": 5000,
      "discount": "150.0",
      "discount_stringified": "150 Tk",
      "effective_mrp": 4850,
      "brand_id": 51,
      "brand_name": "Local Brand New",
      "brand_name_bn": "Local Brand New",
      "variant_id": 2954,
      "is_wishlisted": false,
      "badge": "150 Tk Discount",
      "bn_badge": "১৫০ টাকা ছাড়",
      "slug": "শীর্ষ-খবর",
      "sell_count": 420,
      "max_quantity_per_order": null,
      "sku_type": "simple_product",
      "root_category": {
        "id": 178,
        "title": "Lifestyle",
        "bn_title": "লাইফস্টাইল",
        "slug": "lifestyle-product"
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
   "message": "Unable to fetched related searched keys",
   "data": {}
}
```
### Search related keys
___

* **URL :** `BASE_URL + /shop/api/v1/search/related_keys/:key`
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
  "status":200,
  "message":"Successfully fetched related keys.",
  "data":["kitk","kit","kit","pat","oat","kit","kitka","kitka","kit","kit"]
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetched related searched keys",
   "data": {}
}
```
