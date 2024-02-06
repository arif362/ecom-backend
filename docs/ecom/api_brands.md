### Fetch own brand list
___

* **URL :** `BASE_URL + /shop/api/v1/brands/own`

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
  "message": "Successfully fetched own brand list.",
  "data": [
    {
      "id": 258,
      "name": "Shurong",
      "bn_name": "সুরঙ",
      "logo": "",
      "is_own_brand": true,
      "slug": "shurong",
      "public_visibility": true,
      "homepage_visibility": true,
      "is_followed": false,
      "redirect_url": ""
    },
    {
      "id": 271,
      "name": "Lenor",
      "bn_name": "লেনর",
      "logo": "",
      "is_own_brand": true,
      "slug": "lenor",
      "public_visibility": true,
      "homepage_visibility": true,
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
   "message": "Unable to fetch own brand list",
   "data": {}
}
```

### Get a specific Brand
___

* **URL :** `BASE_URL + /shop/api/v1/brands/:slug`

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
  "message": "Brand fetched successfully",
  "data": {
    "id": 173,
    "name": "ACI",
    "bn_name": "এসিআই",
    "logo": null,
    "banners": [],
    "is_own_brand": false,
    "slug": "aci",
    "brand_info_visible": false,
    "brand_info": {
      "branding_layout": "full",
      "branding_promotion_with": "image",
      "branding_video_url": "",
      "branding_image": "",
      "branding_title": "",
      "branding_title_bn": "",
      "branding_subtitle": "",
      "branding_subtitle_bn": "",
      "short_description": "",
      "short_description_bn": "",
      "more_info_button_text": "",
      "more_info_button_text_bn": "",
      "more_info_url": ""
    },
    "meta_info": {
      "meta_title": "ACI",
      "bn_meta_title": "এসিআই",
      "meta_description": "Buy high-quality products from ACI brought to you by Shopoth.com. Order online and get pick & pay delivery from anywhere in Bangladesh.",
      "bn_meta_description": "সাশ্রয়ী মূল্যে শপথ থেকে এসিআই এর প্রোডাক্টগুলো ক্রয় করুন! অনলাইনে এই প্রোডাক্টগুলো অর্ডার করুন অথবা আপনার নিকটস্থ যেকোনো শপথ পার্টনার আউটলেট থেকে পিক অ্যান্ড পে ডেলিভারী সেবাটি গ্রহণ করুন।",
      "meta_keyword": [],
      "bn_meta_keyword": []
    },
    "is_followed": false,
    "campaigns": [],
    "category_filter_options": null,
    "product_attribute_filter_options": null,
    "price_filter_options": null,
    "product_type_filter_options": null,
    "keyword_filter_options": null,
    "redirect_url": ""
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
   "message": "Unable to fetch Brand details",
   "data": {}
}
```
### Follow a Brand
___

* **URL :** `BASE_URL + /shop/api/v1/brands/:slug/follow`

* **Method :** `POST`

* **URL Params :**

```json
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "message": "Brand followed successfully.",
  "status_code": 200
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to follow brand",
   "data": {}
}
```
### Unollow a Brand
___

* **URL :** `BASE_URL + /shop/api/v1/brands/:slug/unfollow`

* **Method :** `DELETE`

* **URL Params :**

```json
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "message": "Brand unfollowed successfully.",
  "status_code": 200
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to unfollow brand",
   "data": {}
}
```
### Brand Categories
___

* **URL :** `BASE_URL + /shop/api/v1/brands/:slug/categories`

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
  "message": "Brand Categories fetched successfully",
  "data": [
    {
      "id": 323,
      "title": "Insect Control",
      "bn_title": "ইনসেক্ট কন্ট্রোল",
      "slug": "insect-spray",
      "image": "https://cdn.shopoth.net/my42yvkrzne0viehw36po1d2h2hk"
    },
    {
      "id": 175,
      "title": "Salt and Sugar",
      "bn_title": "লবণ এবং চিনি",
      "slug": "salt-sugar",
      "image": "https://cdn.shopoth.net/mbbn6fdt7h8yqal6wbflg3g3bwz4"
    },
    {
      "id": 208,
      "title": "Bath Soap",
      "bn_title": "বাথ সোপ",
      "slug": "bath-soap",
      "image": "https://cdn.shopoth.net/34da0u9gtavairnynvdiiopruu2v"
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
   "message": "Unable to get Brand categories",
   "data": {}
}
```
### Filter brand products
___

* **URL :** `BASE_URL + /shop/api/v1/brands/:slug/filter`

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
  "message": "Brand products fetched successfully",
  "data": [
    {
      "id": 4204,
      "title": "ACI Black fighter Coil Max classic 12 HR",
      "bn_title": "এসিআই ব্ল্যাক ফাইটার কয়েল ম্যাক্স ক্লাসিক ১২ এইচআর",
      "image_url": "",
      "view_url": "/products/details/4204",
      "price": 60,
      "discount": "0",
      "discount_stringified": "0 Tk",
      "effective_mrp": 60,
      "brand_id": 173,
      "brand_name": "ACI",
      "brand_name_bn": "এসিআই",
      "variant_id": 4804,
      "is_wishlisted": false,
      "badge": "",
      "bn_badge": "",
      "slug": "aci-black-fighter-coil-max-classic-12-hr",
      "sell_count": 26,
      "max_quantity_per_order": 5,
      "sku_type": "simple_product",
      "root_category": {
        "id": 12,
        "title": "Health and Hygiene",
        "bn_title": "হেলথ এন্ড হাইজিন",
        "slug": "health-hygiene"
      },
      "available_quantity": 0,
      "is_available": false,
      "is_requested": false
    }
  ]
}
```
* **Error Response**
 * **Code :**`404`
 * **Content :**
```json
{
  "success": false,
  "status": 404,
  "message": "Brand not found.",
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
   "message": "Unable to get Brand products",
   "data": {}
}
```


