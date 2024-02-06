**Promo Banner APIS**
----

### Get visible promo_banners for ecommerce:

* **URL**: `BASE_URL + shop/api/v1/promo_banners`

* **Method:** `GET`

* **Authentication**
  `Auth optional`

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched promo banners.",
  "data": [
    {
      "id": 20,
      "title": "Test promo banner",
      "layout": 2,
      "is_visible": true,
      "app_images": [
        {
          "id": 4,
          "image_title": "app image 1",
          "description": "app image description",
          "image_type": "app",
          "redirect_url": "http://internal.misfit.tech/",
          "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/ebhk90c3cigpcyxv7jwxs6rnslrt?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=059707c32609424e54315c6118605b8126edaca4bdab11e158049a8dc6449cf1"
        },
        {
          "id": 5,
          "image_title": "app image 2",
          "description": "app image description",
          "image_type": "app",
          "redirect_url": "http://internal.misfit.tech/",
          "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/u5x2qyj6sq8r43jdh22cmjfawf18?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=58187d22a9ffd4c9947972bde6ec12a09a1a0cf283ead0fd81f5f0e9ef7e9766"
        }
      ],
      "web_images": [
        {
          "id": 6,
          "image_title": "web image 1",
          "description": "web image description",
          "image_type": "web",
          "redirect_url": "http://internal.misfit.tech/",
          "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/1ejkmsfr3jp1tx4sx55a4ux6tkyq?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=255b2280cf6b41e0aeb1aaee767b2e76606a787933f2e0ba61b7ac1b84e36d77"
        },
        {
          "id": 7,
          "image_title": "web image 2",
          "description": "web image description",
          "image_type": "web",
          "redirect_url": "http://internal.misfit.tech/",
          "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/ath7sz4062bspmhrhf18lfdtk3yd?response-content-disposition=inline%3B%20filename%3D%224%253F%253F%253F%253F%253F.png%22%3B%20filename%2A%3DUTF-8%27%274%25E3%2580%2581%25E5%25AD%2598%25E7%25AE%2597%25E4%25B8%2580%25E4%25BD%2593.png&response-content-type=image%2Fpng&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=4a68ba90935e65f8526f5db7a4c091a38c832b329de48c7eb3e0f079a1ea40ef"
        }
      ]
    }
  ]
}
```

* **Code:** `200`
    * **Error Response:**
        * **Code:** `422`
        * **Content(example):**
             ```json 
          {
             "success": false,
             "status": 200,
             "message": "Unable to fetch promo banner.",
             "data": {}
          }
           ```

### Get all promo banner:

* **URL**: `BASE_URL + /api/v1/promo_banners`

* **Method:** `GET`

* **Authentication**
  `Staff auth`

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched promo banner.",
  "data": [
    {
      "id": 20,
      "title": "Test promo banner",
      "layout": 2,
      "is_visible": true,
      "app_images": [
        {
          "id": 4,
          "image_title": "app image 1",
          "description": "app image description",
          "image_type": "app",
          "redirect_url": "http://internal.misfit.tech/",
          "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/ebhk90c3cigpcyxv7jwxs6rnslrt?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=059707c32609424e54315c6118605b8126edaca4bdab11e158049a8dc6449cf1"
        },
        {
          "id": 5,
          "image_title": "app image 2",
          "description": "app image description",
          "image_type": "app",
          "redirect_url": "http://internal.misfit.tech/",
          "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/u5x2qyj6sq8r43jdh22cmjfawf18?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=58187d22a9ffd4c9947972bde6ec12a09a1a0cf283ead0fd81f5f0e9ef7e9766"
        }
      ],
      "web_images": [
        {
          "id": 6,
          "image_title": "web image 1",
          "description": "web image description",
          "image_type": "web",
          "redirect_url": "http://internal.misfit.tech/",
          "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/1ejkmsfr3jp1tx4sx55a4ux6tkyq?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=255b2280cf6b41e0aeb1aaee767b2e76606a787933f2e0ba61b7ac1b84e36d77"
        },
        {
          "id": 7,
          "image_title": "web image 2",
          "description": "web image description",
          "image_type": "web",
          "redirect_url": "http://internal.misfit.tech/",
          "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/ath7sz4062bspmhrhf18lfdtk3yd?response-content-disposition=inline%3B%20filename%3D%224%253F%253F%253F%253F%253F.png%22%3B%20filename%2A%3DUTF-8%27%274%25E3%2580%2581%25E5%25AD%2598%25E7%25AE%2597%25E4%25B8%2580%25E4%25BD%2593.png&response-content-type=image%2Fpng&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=4a68ba90935e65f8526f5db7a4c091a38c832b329de48c7eb3e0f079a1ea40ef"
        }
      ]
    }
  ]
}
```

* **Code:** `200`
    * **Error Response:**
        * **Code:** `422`
        * **Content(example):**
             ```json 
          {
             "success": false,
             "status": 200,
             "message": "Unable to fetch promo banner.",
             "data": {}
          }
           ```

### Get a specific promo banner:

* **URL**: `BASE_URL + /api/v1/promo_banners/:id`

* **Method:** `GET`

* **Authentication**
  `Staff auth`

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched promo banner.",
  "data": {
    "id": 20,
    "title": "Test promo banner",
    "layout": 2,
    "is_visible": true,
    "app_images": [
      {
        "id": 4,
        "image_title": "app image 1",
        "description": "app image description",
        "image_type": "app",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/ebhk90c3cigpcyxv7jwxs6rnslrt?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=059707c32609424e54315c6118605b8126edaca4bdab11e158049a8dc6449cf1"
      },
      {
        "id": 5,
        "image_title": "app image 2",
        "description": "app image description",
        "image_type": "app",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/u5x2qyj6sq8r43jdh22cmjfawf18?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=58187d22a9ffd4c9947972bde6ec12a09a1a0cf283ead0fd81f5f0e9ef7e9766"
      }
    ],
    "web_images": [
      {
        "id": 6,
        "image_title": "web image 1",
        "description": "web image description",
        "image_type": "web",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/1ejkmsfr3jp1tx4sx55a4ux6tkyq?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=255b2280cf6b41e0aeb1aaee767b2e76606a787933f2e0ba61b7ac1b84e36d77"
      },
      {
        "id": 7,
        "image_title": "web image 2",
        "description": "web image description",
        "image_type": "web",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/ath7sz4062bspmhrhf18lfdtk3yd?response-content-disposition=inline%3B%20filename%3D%224%253F%253F%253F%253F%253F.png%22%3B%20filename%2A%3DUTF-8%27%274%25E3%2580%2581%25E5%25AD%2598%25E7%25AE%2597%25E4%25B8%2580%25E4%25BD%2593.png&response-content-type=image%2Fpng&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T102512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=4a68ba90935e65f8526f5db7a4c091a38c832b329de48c7eb3e0f079a1ea40ef"
      }
    ]
  }
}
```

* **Code:** `200`
    * **Error Response:**
        * **Code:** `422`
        * **Content(example):**
             ```json 
          {
             "success": false,
             "status": 200,
             "message": "Unable to fetch promo banner.",
             "data": {}
          }
           ```

### Create a promo banner:

* **URL**: `BASE_URL + /api/v1/promo_banners`

* **Method:** `POST`

* **Authentication**
  `Staff auth`

* **URL Params:**
   ```json
  {
     "title": "Test promo banner",
     "layout": 2,
     "is_visible": true,
     "banner_images_attributes": [
        {
          "image_title": "app image 1",
          "description": "app image description",
          "image_type": "app",
          "redirect_url": "http://internal.misfit.tech/",
          "image_file": File
        },
        {
          "image_title": "app image 2",
          "description": "app image description",
          "image_type": "app",
          "redirect_url": "http://internal.misfit.tech/",
          "image_file": File
        },
        {
          "image_title": "web image 1",
          "description": "web image description",
          "image_type": "web",
          "redirect_url": "http://internal.misfit.tech/",
          "image_file": File
        },
        {
          "image_title": "web image 2",
          "description": "web image description",
          "image_type": "web",
          "redirect_url": "http://internal.misfit.tech/",
          "image_file": File
        }
      ]
  }
  ```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully created promo banner.",
  "data": {
    "id": 13,
    "title": "Test promo banner",
    "layout": 2,
    "is_visible": true,
    "app_images": [
      {
        "image_title": "app image 1",
        "description": "app image description",
        "image_type": "app",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/cdwb5oti0f1rl6tqrf99uw1rf54m?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T080853Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=583daec2412044f82a212f93a707fb6c45bf4671e02957a9cbfe5dc438d52c45"
      },
      {
        "image_title": "app image 2",
        "description": "app image description",
        "image_type": "app",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/mjgbts8vmyxcazvyj56e608cf1sp?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T080853Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=5682b3a3ae49147082755e5872caf1b01479bd6bc8aefd60de10b973b63985dc"
      }
    ],
    "web_images": [
      {
        "image_title": "web image 1",
        "description": "web image description",
        "image_type": "web",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/agy8sijwk2iy5lf05nwk9w8rexrp?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T080853Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=57426fa7d3f8731def86be64b6d93af40b6dab10feab37e0c039bb2a9585604b"
      },
      {
        "image_title": "web image 2",
        "description": "web image description",
        "image_type": "web",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/9jjikq2475910uv6in6suaaknz2c?response-content-disposition=inline%3B%20filename%3D%224%253F%253F%253F%253F%253F.png%22%3B%20filename%2A%3DUTF-8%27%274%25E3%2580%2581%25E5%25AD%2598%25E7%25AE%2597%25E4%25B8%2580%25E4%25BD%2593.png&response-content-type=image%2Fpng&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T080853Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=0a71813d0f68f5733e0bb71e60a160ab1f48fec7a9d2a9acabcd17b0b3b923f5"
      }
    ]
  }
}
```

* **Code:** `200`
    * **Error Response:**
        * **Code:** `422`
        * **Content(example):**
             ```json 
          {
             "success": false,
             "status": 200,
             "message": "Unable to create promo banner. error: error_message",
             "data": {}
          }
          ```

### Update a promo banner:

* **URL**: `BASE_URL + /api/v1/promo_banners/:id`

* **Method:** `PUT`

* **Authentication**
  `Staff auth`

* **URL Params:**
   ```json
  {
     "banner_images_attributes": [
        {
          "id": 5,
          "image_type": "app",
          "redirect_url": "http://internal.misfit.tech/",
          "image_file": File
  
        },
        {
          "id": 7,
          "image_type": "app",
          "redirect_url": "http://internal.misfit.tech/",
          "image_file": File
  
        }
      ]
  }
  ```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully created promo banner.",
  "data": {
    "id": 13,
    "title": "Test promo banner",
    "layout": 2,
    "is_visible": true,
    "app_images": [
      {
        "image_title": "app image 1",
        "description": "app image description",
        "image_type": "app",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/cdwb5oti0f1rl6tqrf99uw1rf54m?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T080853Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=583daec2412044f82a212f93a707fb6c45bf4671e02957a9cbfe5dc438d52c45"
      },
      {
        "image_title": "app image 2",
        "description": "app image description",
        "image_type": "app",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/mjgbts8vmyxcazvyj56e608cf1sp?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T080853Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=5682b3a3ae49147082755e5872caf1b01479bd6bc8aefd60de10b973b63985dc"
      }
    ],
    "web_images": [
      {
        "image_title": "web image 1",
        "description": "web image description",
        "image_type": "web",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/agy8sijwk2iy5lf05nwk9w8rexrp?response-content-disposition=attachment%3B%20filename%3D%22slider.webp%22%3B%20filename%2A%3DUTF-8%27%27slider.webp&response-content-type=image%2Fwebp&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T080853Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=57426fa7d3f8731def86be64b6d93af40b6dab10feab37e0c039bb2a9585604b"
      },
      {
        "image_title": "web image 2",
        "description": "web image description",
        "image_type": "web",
        "redirect_url": "http://internal.misfit.tech/",
        "image_url": "https://s3.ap-southeast-1.amazonaws.com/cdn.shopoth.net/9jjikq2475910uv6in6suaaknz2c?response-content-disposition=inline%3B%20filename%3D%224%253F%253F%253F%253F%253F.png%22%3B%20filename%2A%3DUTF-8%27%274%25E3%2580%2581%25E5%25AD%2598%25E7%25AE%2597%25E4%25B8%2580%25E4%25BD%2593.png&response-content-type=image%2Fpng&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJL7GQ4HKOXWXIOS%2F20220612%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220612T080853Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=0a71813d0f68f5733e0bb71e60a160ab1f48fec7a9d2a9acabcd17b0b3b923f5"
      }
    ]
  }
}
```

* **Code:** `200`
    * **Error Response:**
        * **Code:** `422`, `404`
        * **Content(example):**
             ```json 
          {
             "success": false,
             "status": 200,
             "message": "Unable to update promo banner. error: error_message",
             "data": {}
          }
          ```

### Delete a promo banner:

* **URL**: `BASE_URL + /api/v1/promo_banners/:id`

* **Method:** `DELETE`

* **Authentication**
  `Staff auth`


* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully deleted promo banner.",
  "data": {}
}
```

* **Code:** `200`
    * **Error Response:**
        * **Code:** `422`, `404`
        * **Content(example):**
             ```json 
          {
             "success": false,
             "status": 200,
             "message": "Unable to delete promo banner.",
             "data": {}
          }
          ```

