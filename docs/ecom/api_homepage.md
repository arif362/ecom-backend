**Homepage API's**
----

Get all the published sliders for homepage

* **URL**: ``BASE_URL + /shop/api/v1/homepage/sliders``

* **Method:** `GET` 
  
*  **URL Params:** `None`

* **Success Response:**
 ```json
{
  "slider_image": [
    {
      "name": "homepage",
      "body": "Samsung is here",
      "link_url": "www.google.com",
      "position": 1,
      "img_type": "slider_img",
      "slider_url": null
    },
    {
      "name": "homepage",
      "body": "Samsung is here",
      "link_url": "www.google.com",
      "position": 1,
      "img_type": "slider_img",
      "slider_url": null
    },
    {
      "name": "homepage",
      "body": "Samsung is here",
      "link_url": "www.google.com",
      "position": 1,
      "img_type": "slider_img",
      "slider_url": null
    },
    {
      "name": "homepage",
      "body": "Samsung is here",
      "link_url": "www.google.com",
      "position": 1,
      "img_type": "slider_img",
      "slider_url": null
    }
  ],
  "banner_image": [
    {
      "name": "homepage",
      "body": "Samsung is here",
      "link_url": "www.google.com",
      "position": 1,
      "img_type": "banner_img",
      "slider_url": "http://localhost:3000/rails/%27%27web_1920_____1.png"
    }
  ]
}
```

  * **Code:** `200`
* **Error Response:**
  * **Code:** `422`
  * **Content:** 
       ```json 
        { "message": "Unable to fetch all the sliders", "status_code": 422 }
       ```


Get all the product sliders

* **URL**: ``BASE_URL + /shop/api/v1/homepage/product_sliders``

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
{
  "bestselling": [],
  "new_arrival": [
    {
      "title": "Trending, new arrival",
      "price": "13100.0",
      "view_url": "/api/v1/products/13"
    }
  ],
  "trending": [
    {
      "title": "Trending, new arrival",
      "price": "13100.0",
      "view_url": "/api/v1/products/13"
    }
  ],
  "daily_deals": []
}
```

* **Code:** `200`
  
* **Error Response:**
  * **Code:** `200`
  * **Content:**
       ```json 
        { "message": "No product in trending, best selling or new arrival list", "status_code": 200 }
       ```

### Use Friendly Search

* **URL**: ``BASE_URL + /shop/api/v1/homepage/friendly_search``

* **Method:** `GET`

* **URL Params:** 
```
  params do
      requires :keyword, type: String
      optional :category_slug, type: String
      optional :warehouse_id, type: Integer
  end
```

* **Success Response:**
 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched searched products.",
  "data": {
    "brands": [
      {
        "id": 86,
        "name": "Meta brand",
        "bn_name": "মেটা ব্র্যান্ড",
        "slug": "শীর্ষ-খবর"
      }
    ],
    "categories": [
      {
        "id": 430,
        "title": "Meta category",
        "bn_title": "মেটা বিভাগ",
        "slug": "meta-category-0-0"
      },
      {
        "id": 431,
        "title": "Meta Sub",
        "bn_title": " মেটা সাব",
        "slug": "meta-sub"
      }
    ],
    "products": [
      {
        "id": 3968,
        "title": "meta Product",
        "bn_title": "",
        "image_url": "",
        "view_url": "/products/details/3968",
        "price": 179,
        "discount": "0",
        "discount_stringified": "0 %",
        "effective_mrp": 179,
        "brand_id": 86,
        "brand_name": "Meta brand",
        "brand_name_bn": "মেটা ব্র্যান্ড",
        "variant_id": 3126,
        "is_wishlisted": false,
        "badge": "New",
        "bn_badge": "নতুন",
        "slug": "সেনাবাহিনী",
        "sell_count": 0,
        "max_quantity_per_order": null,
        "sku_type": "variable_product",
        "root_category": null,
        "available_quantity": 0,
        "is_available": false,
        "is_requested": false
      }
    ]
  }
}
```

* **Error Response:**
  * **Code:** `200`
  * **Content:**
       ```json 
        { "success": false, message": "Unable to fetch searched products.", "status": 422, "data": {} }
       ```

* **If category_slug given but not found in the database**
  * **Code:** `200`
  * **Content:**
       ```json 
        { "success": false, message": "Unable to find category.", "status": 404, "data": {} }
       ```
* **If warehouse_id given but not found in the database**
  * **Code:** `200`
  * **Content:**
       ```json 
        { "success": false, message": "Unable to find warehouse.", "status": 404, "data": {} }
       ```

Footer information: [Footer API](docs/api_footer.md)

### Get homepage navigation category
___

* **URL :** `BASE_URL + /shop/api/v1/homepage/navigation_categories`
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
  "message": "Successfully fetched categories.",
  "data": [
    {
      "id": 347,
      "title": "Snacks & Beverages",
      "bn_title": "স্নাক্স এন্ড বেভারেজেস",
      "slug": "snacks-beverages",
      "image": "http://cdn.shopoth.net/ybtv5q7t9c41hmfoot90j3y3jo56",
      "sub_categories": [
        {
          "id": 403,
          "title": "test cat",
          "bn_title": "ফিচার ফোন",
          "slug": "test-cat",
          "view_url": "/product_category/test-cat",
          "sub_categories": []
        },
        {
          "id": 348,
          "title": "25754735423542",
          "bn_title": "সুমন",
          "slug": "25754735423542",
          "view_url": "/product_category/25754735423542",
          "sub_categories": []
        }
      ]
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
   "message": "Unable to fetch categories",
   "data": {}
}
```
### Get all flash sales product
___

* **URL :** `BASE_URL + /shop/api/v1/homepage/flash_sales`
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
  "message": "Successfully fetched flash sale products.",
  "data": {
    "id": 222,
    "title": "summer sale",
    "bn_title": "summer sale bangla",
    "start_at": "2022-06-06T10:59:00.000+06:00",
    "end_at": "2022-12-30T18:00:00.000+06:00",
    "current_date": "2022-12-20T15:17:32.656+06:00",
    "active": true,
    "products": [
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
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch",
   "data": {}
}
```
### Get all products by category
___

* **URL :** `BASE_URL + /shop/api/v1/homepage/category_products`
* **Method :** `GET`
* **URL Params :**

```json
{
  "category": "bundles"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "result": [
    {
      "id": 3946,
      "title": "Sumon Bundle 2",
      "bn_title": "সুমন বান্ডিল দুই",
      "image_url": "http://cdn.shopoth.net/variants/heernz3p62j22w4q8ll9g8efiddw/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
      "view_url": "/products/details/3946",
      "price": 200,
      "discount": "0",
      "discount_stringified": "0 %",
      "effective_mrp": 200,
      "brand_id": 42,
      "brand_name": "Sumon",
      "brand_name_bn": "Sumon",
      "variant_id": 3094,
      "is_wishlisted": false,
      "badge": "",
      "bn_badge": "",
      "slug": "sumon-bundle-22",
      "sell_count": 1,
      "max_quantity_per_order": null,
      "sku_type": "bundle_product",
      "available_quantity": 0,
      "is_available": false,
      "is_requested": false
    }
  ]
}
```
### Homepage product search
___

* **URL :** `BASE_URL + /shop/api/v1/homepage/search`
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
    },
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
   "message": "Unable to fetch search products",
   "data": {}
}
```
### Homepage Get all brand
___

* **URL :** `BASE_URL + /shop/api/v1/homepage/all-brands`
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
  "message": "Successfully fetched brands.",
  "data": [
    {
      "id": 69,
      "name": "Gorur Ghash lifedfdfdfdfd",
      "bn_name": "গোরুর ঘাষ",
      "logo": "http://cdn.shopoth.net/n1od09ois56bl7g35cjd9hm36r9o",
      "is_own_brand": false,
      "slug": "gorur-ghashhsajgxhaihishhxdjjojo",
      "public_visibility": true,
      "homepage_visibility": false,
      "is_followed": false,
      "redirect_url": ""
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
   "message": "Unable to fetch brands",
   "data": {}
}
```
### Get list of shop by brand
___

* **URL :** `BASE_URL + /shop/api/v1/homepage/shop_by_brand`
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
  "message": "Successfully fetched brands.",
  "data": [
    {
      "id": 69,
      "name": "Gorur Ghash lifedfdfdfdfd",
      "bn_name": "গোরুর ঘাষ",
      "logo": "http://cdn.shopoth.net/n1od09ois56bl7g35cjd9hm36r9o",
      "is_own_brand": false,
      "slug": "gorur-ghashhsajgxhaihishhxdjjojo",
      "public_visibility": true,
      "homepage_visibility": false,
      "is_followed": false,
      "redirect_url": ""
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
   "message": "Unable to fetch brands",
   "data": {}
}
```
### Subscribe to newsLetter
___

* **URL :** `BASE_URL + /shop/api/v1/homepage/news_letters/subscribe`
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
  "status": 200,
  "message": "Successfully subscribed",
  "data": {}
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
  "success": false,
  "status": 403,
  "message": "You are already subscribed.",
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
   "message": "Unable to subscribed",
   "data": {}
}
```
### Unsubscribe from newsLetter
___

* **URL :** `BASE_URL + /shop/api/v1/homepage/news_letters/unsubscribe`
* **Method :** `PUT`
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
  "message": "Successfully unsubscribed from newsletter",
  "data": {}
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": false,
  "status": 404,
  "message": "Unable to find newsletter.",
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
   "message": "Unable to unsubscribe newsletter",
   "data": {}
}
```
