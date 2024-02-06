### Get all Brands with pagination.
___

* **URL :** `BASE_URL + /api/v1/brands/paginated`
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
  "message": "Brands fetched successfully",
  "data": [
    {
      "id": 114,
      "name": "ACI",
      "bn_name": "ACI BN",
      "slug": "aci",
      "logo_file": null,
      "banners": [
        {
          "id": 8756,
          "url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/kwwdsq8kbxzw9s22tvrxdtbizmda?response-content-disposition=inline%3B%20filename%3D%221440x400.jpg%22%3B%20filename%2A%3DUTF-8%27%271440x400.jpg\u0026response-content-type=image%2Fjpeg\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T115045Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=43d52d2e0664e65e58c7c45615d89f4c196e0e6852098137947b0a41f54f093d"
        }
      ],
      "is_own_brand": false,
      "brand_info_visible": false,
      "public_visibility": true,
      "homepage_visibility": false,
      "branding_layout": "full",
      "branding_promotion_with": "image",
      "branding_video_url": null,
      "branding_image_file": null,
      "branding_title": null,
      "branding_title_bn": null,
      "branding_subtitle": null,
      "branding_subtitle_bn": null,
      "short_description": null,
      "short_description_bn": null,
      "more_info_button_text": null,
      "more_info_button_text_bn": null,
      "more_info_url": null,
      "product_count": 2,
      "campaigns_attributes": [],
      "filtering_options_attributes": [],
      "redirect_url": null,
      "meta_info": null,
      "created_by": {
        "id": 109,
        "name": "Central Admin"
      }
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
### Brand Details
___

* **URL :** `BASE_URL + /api/v1/brands/:id`
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
  "message": "Brands fetched successfully",
  "data": 
  {
    "id": 114,
    "name": "ACI",
    "bn_name": "ACI BN",
    "slug": "aci",
    "logo_file": null,
    "banners": [
      {
        "id": 8756,
        "url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/kwwdsq8kbxzw9s22tvrxdtbizmda?response-content-disposition=inline%3B%20filename%3D%221440x400.jpg%22%3B%20filename%2A%3DUTF-8%27%271440x400.jpg\u0026response-content-type=image%2Fjpeg\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T115045Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=43d52d2e0664e65e58c7c45615d89f4c196e0e6852098137947b0a41f54f093d"
      }
    ],
    "is_own_brand": false,
    "brand_info_visible": false,
    "public_visibility": true,
    "homepage_visibility": false,
    "branding_layout": "full",
    "branding_promotion_with": "image",
    "branding_video_url": null,
    "branding_image_file": null,
    "branding_title": null,
    "branding_title_bn": null,
    "branding_subtitle": null,
    "branding_subtitle_bn": null,
    "short_description": null,
    "short_description_bn": null,
    "more_info_button_text": null,
    "more_info_button_text_bn": null,
    "more_info_url": null,
    "product_count": 2,
    "campaigns_attributes": [],
    "filtering_options_attributes": [],
    "redirect_url": null,
    "meta_info": null,
    "created_by": {
      "id": 109,
      "name": "Central Admin"
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
   "message": "Unable to fetch Brand details.",
   "data": {}
}
```
### Brand Create
___

* **URL :** `BASE_URL + /api/v1/brands`
* * **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "brand": {
    "name": "Aagami Brand",
    "bn_name": "Aagami Brand bn",
    "brand_info_visible": true,
    "public_visibility": true,
    "homepage_visibility": true,
    "slug": "aagami-brand",
    "branding_layout": "box",
    "branding_promotion_with": "image",
    "branding_title": "Aagami Brand",
    "short_description": "<p>Aagami Brand</p>",
    "short_description_bn": "<p>Aagami Brand</p>",
    "branding_title_bn": "Aagami Brand Bn"
  }
 
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Brand created successfully",
  "data":{}
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to create Brand: #{error.message}",
   "data": {}
}
```
### Brand Update
___

* **URL :** `BASE_URL + /api/v1/brands/:id`
* * **Method :** `PUT`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "brand": {
    "name": "Aagami Brand",
    "bn_name": "Aagami Brand bn",
    "brand_info_visible": true,
    "public_visibility": true,
    "homepage_visibility": true,
    "slug": "aagami-brand",
    "branding_layout": "box",
    "branding_promotion_with": "image",
    "branding_title": "Aagami Brand",
    "short_description": "<p>Aagami Brand</p>",
    "short_description_bn": "<p>Aagami Brand</p>",
    "branding_title_bn": "Aagami Brand Bn"
  }
 
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Brand updated successfully",
  "data":{}
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to update Brand du to #{error.message}",
   "data": {}
}
```
### Brand Delete
___

* **URL :** `BASE_URL + /api/v1/brands/:id`
* * **Method :** `DELETE`
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
  "message": "Brand deleted successfully",
  "data":{}
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to delete",
   "data": {}
}
```
### Delete a specific Brand's banner.
___

* **URL :** `BASE_URL + /api/v1/brands/:id/delete_banner`
* * **Method :** `DELETE`
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
  "message": "Successfully deleted brand's banner image.",
  "data":{}
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to delete brand's banner image.",
   "data": {}
}
```
