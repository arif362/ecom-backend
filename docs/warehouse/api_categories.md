### Return list of categories.
___

* **URL :** `BASE_URL + /api/v1/categories/list`
* **Method :** `GET`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id":467,
    "title":"Personal Care",
    "position":2,
    "description":null,
    "slug":"personal-care",
    "parent_id":null,
    "parent":null,
    "parent_category":null,
    "bn_title":"পার্সোনাল কেয়ার",
    "image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/ge7tlkpzqg4rktb2aiaz9ln2a0j2?response-content-disposition=inline%3B%20filename%3D%22Personal%20Care%20%25281%2529.png%22%3B%20filename%2A%3DUTF-8%27%27Personal%2520Care%2520%25281%2529.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T130755Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=d9ab1014dedaae286d8ae3c9ac4983a8ac07360cfd29196d747a8b884a3835e8",
    "banner_image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/q8gwo5vec95ebist8f7p0utdiscc?response-content-disposition=inline%3B%20filename%3D%22Personal%20Care.png%22%3B%20filename%2A%3DUTF-8%27%27Personal%2520Care.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T130755Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=4ed7c8f7d19994d209b0d2b38f7f2889a05eab88cfcdbd5440dd652ab937b100",
    "bn_description":null,
    "home_page_visibility":true,
    "sub_categories":[
      {
        "id":468,
        "title":"Skin and Body Care",
        "position":1,
        "description":null,
        "slug":"skin-and-body-care",
        "parent_id":467,
        "parent":"Personal Care",
        "parent_category":
        {
          "id":467,
          "title":"Personal Care",
          "parent_category":null
        },
        "bn_title":"Skin and Body Care bn",
        "image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/g2dgf36wfj65zl76z0lmlkf9whaz?response-content-disposition=inline%3B%20filename%3D%2212.04.2022_16.00.45_REC.png%22%3B%20filename%2A%3DUTF-8%27%2712.04.2022_16.00.45_REC.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T130755Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=92935fdbafb44c23de28d1b224297fb8a1f3d7535e6a59fd630c3a0147eb8d91",
        "banner_image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/kgw4spyb60ia6lr28qytdicp7yst?response-content-disposition=inline%3B%20filename%3D%22300x200.png%22%3B%20filename%2A%3DUTF-8%27%27300x200.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T130755Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=d89445cceff250630f6b0e01f372d2b543c0dcc22e4034aa17c35c9d18e4c96f",
    "bn_description":null,
    "home_page_visibility":true,
    "sub_categories":[
      {
        "id":469,
        "title":"Soap",
        "position":2,
        "description":null,
        "slug":"soap",
        "parent_id":468,
        "parent":"Skin and Body Care",
        "parent_category":
        {
          "id":468,
          "title":"Skin and Body Care",
          "parent_category":
          {
            "id":467,
            "title":"Personal Care",
            "parent_category":null
          }
        },
        "bn_title":"Soap bn",
        "image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/e22tuukprhsd0cx9nwptgkte3gak?response-content-disposition=inline%3B%20filename%3D%22354x440.png%22%3B%20filename%2A%3DUTF-8%27%27354x440.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T130755Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=1c4af1e8333f7e9d89fee3a246eaf063e4b841a525da1b36f0d4e862cf58e7f7",
        "banner_image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/jcfktf2s80sfvbtxa0oiu6u2ky85?response-content-disposition=inline%3B%20filename%3D%22300x400.png%22%3B%20filename%2A%3DUTF-8%27%27300x400.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T130755Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=995cb748fb83d91f43677a1ed62373358aa7415c6b870fcc6cfc2f3a23034257",
        "bn_description":null,
        "home_page_visibility":true,
        "sub_categories":[],
        "meta_info":null,
        "business_type":"both",
        "created_by":{
          "id":109,
          "name":"Central Admin"
        }
      }
    ],
    "meta_info":null,
    "business_type":"both",
        "created_by":{
      "id":109,
      "name":"Central Admin"
    }
  }
  ],
    "meta_info":null,
    "business_type":"both",
    "created_by":{
      "id":109,
      "name":"Central Admin"
    }
  }
]
```


* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch categories.",
   "data": {}
}
```
### Create category
___

* **URL :** `BASE_URL + /api/v1/categories`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "category":{
    "image_file": "",
    "banner_image_file": "",
    "slug": "pants",
    "business_type": "b2c",
    "title": "Pants",
    "bn_title": "Category Care",
    "position": 3,
    "home_page_visibility": 1,
    "parent_id": 178
  }
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "id":481,
  "title":"Pants",
  "position":3,
  "description":null,
  "slug":"pants",
  "parent_id":178,
  "parent":"Lifestyle",
  "parent_category":
  {
    "id":178,
    "title":"Lifestyle",
    "parent_category":null
  },
  "bn_title":"Category Care",
  "image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/ynir29kuxu067ytr0rad6z3751wt?response-content-disposition=inline%3B%20filename%3D%22Screenshot%20from%202022-06-12%2009-51-44.png%22%3B%20filename%2A%3DUTF-8%27%27Screenshot%2520from%25202022-06-12%252009-51-44.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T130755Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=614dd7fbce8776ea2f355747b27d2cbf9ed8876e9fcb00b7e096a787328a65a8",
  "banner_image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/xjrp6rg9hh1d23kcf38lc5eioqhx?response-content-disposition=inline%3B%20filename%3D%22Screenshot%20from%202022-06-30%2012-06-34.png%22%3B%20filename%2A%3DUTF-8%27%27Screenshot%2520from%25202022-06-30%252012-06-34.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T130755Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=49892dbedea9a45f7798de6ab99a39346f61f6f75fea515b2e26bed07e78a712",
  "bn_description":null,
  "home_page_visibility":true,
  "sub_categories":[],
  "meta_info":null,
  "business_type":"b2c",
  "created_by":
  {
    "id":108,
    "name":"Central Admin"
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
   "message": "Unable to create category due to: #{error.message}",
   "data": {}
}
```
### Category Details
___

* **URL :** `BASE_URL + /api/v1/categories/:id`
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
  "id":468,
  "title":"Skin and Body Care",
  "position":1,
  "description":null,
  "slug":"skin-and-body-care",
  "parent_id":467,"parent":"Personal Care",
  "parent_category":{
    "id":467,
    "title":"Personal Care",
    "parent_category":null
  },
  "bn_title":"Skin and Body Care bn",
  "image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/g2dgf36wfj65zl76z0lmlkf9whaz?response-content-disposition=inline%3B%20filename%3D%2212.04.2022_16.00.45_REC.png%22%3B%20filename%2A%3DUTF-8%27%2712.04.2022_16.00.45_REC.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T132717Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=2fb250420143af44ca93b2b9080ab1b79137fb456e4653d0444ff0c36a34ef62",
  "banner_image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/kgw4spyb60ia6lr28qytdicp7yst?response-content-disposition=inline%3B%20filename%3D%22300x200.png%22%3B%20filename%2A%3DUTF-8%27%27300x200.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T132717Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=654f20566837ef86b4ed17d012f45b46c748b753f4f82fb377696cceca992075",
  "bn_description":null,
  "home_page_visibility":true,
  "sub_categories":[
    {
      "id":469,
      "title":"Soap",
      "position":2,
      "description":null,
      "slug":"soap",
      "parent_id":468,
      "parent":"Skin and Body Care",
      "parent_category":{
        "id":468,
        "title":"Skin and Body Care",
        "parent_category":{
          "id":467,
          "title":"Personal Care",
          "parent_category":null
        }
      },
      "bn_title":"Soap bn",
      "image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/e22tuukprhsd0cx9nwptgkte3gak?response-content-disposition=inline%3B%20filename%3D%22354x440.png%22%3B%20filename%2A%3DUTF-8%27%27354x440.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T132717Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=8510c536ac29496b3e9b64659cfd5ea34459aa7c168da45d2cab6e19af4c2f31",
      "banner_image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/jcfktf2s80sfvbtxa0oiu6u2ky85?response-content-disposition=inline%3B%20filename%3D%22300x400.png%22%3B%20filename%2A%3DUTF-8%27%27300x400.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T132717Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=6d869c7fd40bf8e8325f1d6e87555fdd62827da2cb94589110b68181828a0bd8",
      "bn_description":null,
      "home_page_visibility":true,
      "sub_categories":[],
      "meta_info":null,
      "business_type":"both",
      "created_by":{
        "id":109,
        "name":"Central Admin"
      }
    }
  ],
  "meta_info":null,
  "business_type":"both",
  "created_by":{
    "id":109,
    "name":"Central Admin"
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
   "message": "Unable to find category with id #{params[:id]} due to #{error.message}",
   "data": {}
}
```
### Category Update
___

* **URL :** `BASE_URL + /api/v1/categories/:id`
* **Method :** `PUT`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "category":{
    "image_file": "",
    "banner_image_file": "",
    "slug": "pants",
    "business_type": "b2c",
    "title": "Pants",
    "bn_title": "Category Care",
    "position": 3,
    "home_page_visibility": 1,
    "parent_id": 178
  }
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "id":481,
  "title":"Pants",
  "position":3,
  "description":null,
  "slug":"pants",
  "parent_id":178,
  "parent":"Lifestyle",
  "parent_category":
  {
    "id":178,
    "title":"Lifestyle",
    "parent_category":null
  },
  "bn_title":"Category Care",
  "image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/ynir29kuxu067ytr0rad6z3751wt?response-content-disposition=inline%3B%20filename%3D%22Screenshot%20from%202022-06-12%2009-51-44.png%22%3B%20filename%2A%3DUTF-8%27%27Screenshot%2520from%25202022-06-12%252009-51-44.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T130755Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=614dd7fbce8776ea2f355747b27d2cbf9ed8876e9fcb00b7e096a787328a65a8",
  "banner_image":"https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/xjrp6rg9hh1d23kcf38lc5eioqhx?response-content-disposition=inline%3B%20filename%3D%22Screenshot%20from%202022-06-30%2012-06-34.png%22%3B%20filename%2A%3DUTF-8%27%27Screenshot%2520from%25202022-06-30%252012-06-34.png\u0026response-content-type=image%2Fpng\u0026X-Amz-Algorithm=AWS4-HMAC-SHA256\u0026X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20221222%2Fap-southeast-1%2Fs3%2Faws4_request\u0026X-Amz-Date=20221222T130755Z\u0026X-Amz-Expires=86400\u0026X-Amz-SignedHeaders=host\u0026X-Amz-Signature=49892dbedea9a45f7798de6ab99a39346f61f6f75fea515b2e26bed07e78a712",
  "bn_description":null,
  "home_page_visibility":true,
  "sub_categories":[],
  "meta_info":null,
  "business_type":"b2c",
  "created_by":
  {
    "id":108,
    "name":"Central Admin"
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
   "message": "Unable to update Category due to #{error.message}.",
   "data": {}
}
```
### Category DELETE
___

* **URL :** `BASE_URL + /api/v1/categories/:id`
* **Method :** `DELETE`
* **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "message": "Successfully deleted",
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
   "message": "Unable to delete",
   "data": {}
}
```

