**Slug APIs**
----
---------------
**Fetch product list**

* **URL**: ``BASE_URL + /shop/api/v1/slugs/products``

* **Method:** `GET`

* **Params:**
     ```json
        "slug": "unisex-fashion",
        brands[]: "liberty",
        brands[]: "lenor",
        "min_price": 500,
        "max_price": 1200,
        "sort_by": "a_to_z",
        "warehouse_id": 8,
        product_attribute_values[]: blue,
        product_attribute_values[]: green,
   ```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched category products.",
  "data": {
    "products": [
      {
        "id": 4337,
        "title": "Liberty Windbreaker Obsidian",
        "bn_title": "লিবার্টি উইন্ডব্রেকার ওবসিডিয়ান",
        "image_url": "",
        "view_url": "/products/details/4337",
        "price": 1500,
        "discount": "350.0",
        "discount_stringified": "350 Tk",
        "effective_mrp": 1150,
        "brand_id": 264,
        "brand_name": "Liberty",
        "brand_name_bn": "লিবার্টি ",
        "variant_id": 5086,
        "is_wishlisted": false,
        "badge": "350 Tk Discount",
        "bn_badge": "৩৫০ টাকা ছাড়",
        "slug": "liberty-windbreaker-obsidian",
        "sell_count": 10,
        "max_quantity_per_order": null,
        "sku_type": "variable_product",
        "available_quantity": 0,
        "is_available": false,
        "is_requested": false
      }
    ],
    "isLastPage": true,
    "page_number": 1
  }
}
```

* **Code:** `200`
* **Error Response:**
    * If any error occurred then:
    * **Code:** `422`
    * **Content:**
         ```json 
          {
                "message": "Unable to fetch category products.",
                "status_code": 404
          }
         ```

### Fetch product list.
___

* **URL :** `BASE_URL + /shop/api/v1/slugs/:slug`
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
  "message": "successfully fetch",
  "data": {
    "slug": "baby-care1",
    "page": "Category",
    "meta_info": {},
    "details": {
      "category": {
        "id": 480,
        "title": "Baby care",
        "bn_title": "বেবি কেয়ার",
        "position": 1,
        "slug": "baby-care1",
        "image": "http://cdn.shopoth.net/znlgpwtq1l1zwtvxqffx2893892m",
        "banner_image": "http://cdn.shopoth.net/variants/q4p43rsdeeyvckj0ecgxm5i4juzu/f6ffd3e7aaae5164e3a3368c20fb813f90e541990d0e179f2c0a1fa30ec2181a",
        "root_parent": {
          "id": 465,
          "title": "Baby Care",
          "bn_title": "বেবি কেয়ার",
          "position": 5,
          "slug": "baby-care",
          "image": "http://cdn.shopoth.net/aq0hh86qyks28gqx4peo3x7pmb93",
          "banner_image": "http://cdn.shopoth.net/vlzkxtia6eyl711ssep69bam1orc",
          "sub_categories": [
            {
              "id": 466,
              "title": "Baby Diapers",
              "bn_title": "baby diapers bangla",
              "position": 1,
              "slug": "baby-diapers",
              "image": "http://cdn.shopoth.net/d4jx5r0b5kyxonj593w2tw5jkmvx",
              "banner_image": "http://cdn.shopoth.net/hoaftvkfqi7modhkg3am095oujey",
              "sub_categories": [
                {
                  "id": 480,
                  "title": "Baby care",
                  "bn_title": "বেবি কেয়ার",
                  "position": 1,
                  "slug": "baby-care1",
                  "image": "http://cdn.shopoth.net/znlgpwtq1l1zwtvxqffx2893892m",
                  "banner_image": "http://cdn.shopoth.net/q4p43rsdeeyvckj0ecgxm5i4juzu",
                  "sub_categories": []
                }
              ]
            }
          ]
        },
        "sub_categories": [],
        "bread_crumbs": [
          {
            "id": 465,
            "title": "Baby Care",
            "description": null,
            "parent_id": null,
            "bn_title": "বেবি কেয়ার",
            "bn_description": null,
            "created_at": "2022-12-11T15:30:07.015+06:00",
            "updated_at": "2022-12-12T15:33:05.467+06:00",
            "home_page_visibility": true,
            "position": 5,
            "slug": "baby-care",
            "created_by_id": 109,
            "business_type": "both",
            "unique_id": "897d5c09-3873-415f-9872-71852955c09f"
          },
          {
            "id": 466,
            "title": "Baby Diapers",
            "description": null,
            "parent_id": 465,
            "bn_title": "baby diapers bangla",
            "bn_description": null,
            "created_at": "2022-12-11T15:31:14.890+06:00",
            "updated_at": "2022-12-11T15:31:44.696+06:00",
            "home_page_visibility": true,
            "position": 1,
            "slug": "baby-diapers",
            "created_by_id": 109,
            "business_type": "both",
            "unique_id": "dec85402-8908-4371-b78e-82060cf2e8c7"
          },
          {
            "id": 480,
            "title": "Baby care",
            "description": null,
            "parent_id": 466,
            "bn_title": "বেবি কেয়ার",
            "bn_description": null,
            "created_at": "2022-12-19T15:52:02.745+06:00",
            "updated_at": "2022-12-19T15:59:44.043+06:00",
            "home_page_visibility": true,
            "position": 1,
            "slug": "baby-care1",
            "created_by_id": 135,
            "business_type": "b2b",
            "unique_id": "c318ecdb-3d9e-4777-9761-3ec573780c22"
          }
        ]
      },
      "brands": [],
      "price_range": {
        "min_price": 0,
        "max_price": 100
      },
      "filter_attributes": []
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
   "message": "#{error}",
   "data": {}
}
```
