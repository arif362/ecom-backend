### Get a specific category details and it's associated brand list
___

* **URL :** `BASE_URL + /shop/api/v1/product_category/:slug`
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
  "success": true,
  "status": 200,
  "message": "Successfully fetched advance filter list.",
  "data": {
    "category": {
      "id": 347,
      "title": "Snacks & Beverages",
      "bn_title": "স্নাক্স এন্ড বেভারেজেস",
      "position": 0,
      "slug": "snacks-beverages",
      "image": "http://cdn.shopoth.net/ybtv5q7t9c41hmfoot90j3y3jo56",
      "banner_image": "http://cdn.shopoth.net/variants/ps0wpp78tp1jyfg7sx8wiu3pr04g/f6ffd3e7aaae5164e3a3368c20fb813f90e541990d0e179f2c0a1fa30ec2181a",
      "root_parent": {
        "id": 347,
        "title": "Snacks & Beverages",
        "bn_title": "স্নাক্স এন্ড বেভারেজেস",
        "position": 0,
        "slug": "snacks-beverages",
        "image": "http://cdn.shopoth.net/ybtv5q7t9c41hmfoot90j3y3jo56",
        "banner_image": "http://cdn.shopoth.net/ps0wpp78tp1jyfg7sx8wiu3pr04g",
        "sub_categories": [
          {
            "id": 348,
            "title": "25754735423542",
            "bn_title": "সুমন",
            "position": null,
            "slug": "25754735423542",
            "image": "http://cdn.shopoth.net/lwetzfi5vk3cy7qprlzx9qli4pma",
            "banner_image": null,
            "sub_categories": []
          },
          {
            "id": 403,
            "title": "test cat",
            "bn_title": "ফিচার ফোন",
            "position": 7,
            "slug": "test-cat",
            "image": "http://cdn.shopoth.net/ce1ar9bb1zb9v120tv1lm5g31v6c",
            "banner_image": "http://cdn.shopoth.net/rwioxvuogjrer6ve3kxitwwfvo50",
            "sub_categories": []
          }
        ]
      },
      "sub_categories": [
        {
          "id": 348,
          "title": "25754735423542",
          "bn_title": "সুমন",
          "position": null,
          "slug": "25754735423542",
          "image": "http://cdn.shopoth.net/lwetzfi5vk3cy7qprlzx9qli4pma",
          "banner_image": null,
          "sub_categories": []
        },
        {
          "id": 403,
          "title": "test cat",
          "bn_title": "ফিচার ফোন",
          "position": 7,
          "slug": "test-cat",
          "image": "http://cdn.shopoth.net/ce1ar9bb1zb9v120tv1lm5g31v6c",
          "banner_image": "http://cdn.shopoth.net/rwioxvuogjrer6ve3kxitwwfvo50",
          "sub_categories": []
        }
      ],
      "bread_crumbs": [
        {
          "id": 347,
          "title": "Snacks & Beverages",
          "description": null,
          "parent_id": null,
          "bn_title": "স্নাক্স এন্ড বেভারেজেস",
          "bn_description": null,
          "created_at": "2021-05-19T17:12:11.911+06:00",
          "updated_at": "2022-12-12T15:09:11.525+06:00",
          "home_page_visibility": true,
          "position": 0,
          "slug": "snacks-beverages",
          "created_by_id": null,
          "business_type": "both",
          "unique_id": "081081a3-819d-4594-a106-979c41284b58"
        }
      ]
    },
    "brands": [
      {
        "id": 72,
        "name": "Mu",
        "bn_name": "Mu",
        "logo": "http://cdn.shopoth.net/variants/6a77304g1gxvfdbqipr2vovd5qwg/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
        "is_own_brand": true,
        "slug": "mumu-143-hi",
        "public_visibility": true,
        "homepage_visibility": false,
        "is_followed": false,
        "redirect_url": "http://v2.shopoth.shop/brands/edit/72"
      },
      {
        "id": 18,
        "name": "test ra category brabd",
        "bn_name": "killua",
        "logo": "http://cdn.shopoth.net/variants/lbv8r8gog04chcclf9hl7tdhp48f/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
        "is_own_brand": false,
        "slug": "test-ra-category-brabd",
        "public_visibility": false,
        "homepage_visibility": false,
        "is_followed": false,
        "redirect_url": null
      },
      {
        "id": 46,
        "name": "'!amsrsajhmsa",
        "bn_name": "'!amsrsajhmsa",
        "logo": "http://cdn.shopoth.net/variants/p4btseykmuog0vupnqt3mrd10gil/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
        "is_own_brand": false,
        "slug": "amsr",
        "public_visibility": false,
        "homepage_visibility": false,
        "is_followed": false,
        "redirect_url": null
      },
      {
        "id": 77,
        "name": "land cruiser",
        "bn_name": "প্রাডো ব্র্যান্ড।",
        "logo": "http://cdn.shopoth.net/variants/q6noner82va7mld951n3cxqzh0vz/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
        "is_own_brand": true,
        "slug": "prado-car-brandoftoyotafftgffggfv1123",
        "public_visibility": true,
        "homepage_visibility": false,
        "is_followed": false,
        "redirect_url": "http://admin.shopoth.shop/brands/edit/77"
      },
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
      },
      {
        "id": 66,
        "name": "Uniliver",
        "bn_name": " ইউনিলিভার",
        "logo": "http://cdn.shopoth.net/variants/xmd6fyef5esaamhx509e6sx758j0/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
        "is_own_brand": false,
        "slug": "uniliverrrryuuuuuuuunnnnnnnnnnuuuuuuuuuuuuuuuuuuuu",
        "public_visibility": true,
        "homepage_visibility": true,
        "is_followed": false,
        "redirect_url": ""
      }
    ],
    "price_range": {
      "min_price": "0.0",
      "max_price": "4997.0"
    },
    "filter_attributes": [
      {
        "id": 50,
        "name": "Earth",
        "bn_name": "Earth",
        "values": [
          {
            "id": 159,
            "value": "Sun",
            "bn_value": "sun"
          },
          {
            "id": 160,
            "value": "\"Moon\"",
            "bn_value": "moon"
          },
          {
            "id": 161,
            "value": "\"Mars\"",
            "bn_value": "mars"
          }
        ]
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
   "message": "Unable to fetch advance filter list.",
   "data": {}
}
```
### Get all products in a category.
___

* **URL :** `BASE_URL + /shop/api/v1/product_category/:slug/products`
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
  "success": true,
  "status": 200,
  "message": "Successfully fetched category products.",
  "data": [
    {
      "id": 3969,
      "title": "Mango",
      "bn_title": "আম",
      "image_url": "http://cdn.shopoth.net/variants/ehgnxfoltdz33dktqq9k0saje4ey/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
      "view_url": "/products/details/3969",
      "price": 299,
      "discount": "0",
      "discount_stringified": "0 %",
      "effective_mrp": 299,
      "brand_id": 77,
      "brand_name": "land cruiser",
      "brand_name_bn": "প্রাডো ব্র্যান্ড।",
      "variant_id": 3128,
      "is_wishlisted": false,
      "badge": "",
      "bn_badge": "",
      "slug": "mango",
      "sell_count": 0,
      "max_quantity_per_order": null,
      "sku_type": "variable_product",
      "available_quantity": 0,
      "is_available": false,
      "is_requested": false
    },
    {
      "id": 3969,
      "title": "Mango",
      "bn_title": "আম",
      "image_url": "http://cdn.shopoth.net/variants/ehgnxfoltdz33dktqq9k0saje4ey/f9e93ed00f659178f5d9dd0219fa6fbda188043a7202d3d8c5b71d4534090099",
      "view_url": "/products/details/3969",
      "price": 299,
      "discount": "0",
      "discount_stringified": "0 %",
      "effective_mrp": 299,
      "brand_id": 77,
      "brand_name": "land cruiser",
      "brand_name_bn": "প্রাডো ব্র্যান্ড।",
      "variant_id": 3128,
      "is_wishlisted": false,
      "badge": "",
      "bn_badge": "",
      "slug": "mango",
      "sell_count": 0,
      "max_quantity_per_order": null,
      "sku_type": "variable_product",
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
   "message": "Unable to fetch category products.",
   "data": {}
}
```
### Get all filter options
___

* **URL :** `BASE_URL + /shop/api/v1/product_category/:id/filter_options`
* **Method :** `GET`
* **URL Params :**

```json
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "categories": [
    {
      "id": 399,
      "name": "Cars"
    },
    {
      "id": 21,
      "name": "Health & Hygiene"
    },
    {
      "id": 323,
      "name": "Cosmetics & Skin Care"
    },
    {
      "id": 330,
      "name": "Electronics & Gadgets"
    },
    {
      "id": 347,
      "name": "Snacks & Beverages"
    }
  ]
}
```
