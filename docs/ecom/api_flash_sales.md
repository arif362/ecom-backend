### Flash sale filter options
___

* **URL :** `BASE_URL + /shop/api/v1/flash_sales/filter_options`
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
  "status": 200,
  "message": "Successfully fetch flash sale products.",
  "data": {
    "flash_sale": {
      "id": 204,
      "title": "Spring Sale",
      "bn_title": "বসন্ত বিক্রয়",
      "start_at": "2022-02-01T12:20:00.000+06:00",
      "end_at": "2022-12-25T12:20:00.000+06:00",
      "current_date": "2022-12-20T13:32:14.703+06:00",
      "active": true,
      "products": []
    },
    "brands": [],
    "filter_attributes": [],
    "price_range": {
      "min_price": 0,
      "max_price": 100
    }
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
   "message": "Fail to fetch due to internal error",
   "data": {}
}
```
### Get products for flash sale
___

* **URL :** `BASE_URL + /shop/api/v1/flash_sales/products`
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
  "status": 200,
  "message": "Successfully fetch flash sale products.",
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
   "message": "Unable to fetch flash sale products",
   "data": {}
}
```
