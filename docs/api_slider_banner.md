**Slider and banner creation API**
----
---------------
Create slider 

**Precondition**: Admin should be authenticated

* **URL**: ``BASE_URL + /api/v1/slides``

* **Method:** `POST`

*  **Form-data Params:** 

constants:
`img_type: { slider_img: 0, banner_img: 1 }`

Request Parameters:
```
link_url: shopoth.com/product/1
image: benson.jpg
published: true
position: 1
body: Caption to display or text to display
img_type: 1 
```

* **Success Response:**
 ```json
{
  "name": "homepage",
  "body": "Samsung is here",
  "link_url": "www.google.com",
  "position": 1,
  "img_type": "banner_img",
  "image": "http://localhost:3000/comentChurn.png"
}
```

* **Code:** `201`
* **Error Response:**
    * If image is  missing
    * **Code:** `404`
    * **Content:**
         ```json 
          {
                "message": "Image is missing!",
                "status_code": 404
          }
         ```
_____________________________
Update slider

* **URL**: ``BASE_URL + /api/v1/slides/:id``

* **Method:** `PUT`

*  **Form-data Params:**
   constants: `img_type: { slider_img: 0, banner_img: 1 }`

Request Parameters:
```
link_url: shopoth.com/product/1
image: benson.jpg
published: true
position: 1
body: Caption to display or text to display
img_type: 1 
```

* **Success Response:**
 ```json
{
  "message": "Successfully updated the slider with id 1",
  "status_code": 200
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          {
                "message": "Unable to update slider with id #{err.message}",
                "status_code": 422
          }
         ```
---------------------------
Delete a slider

* **URL**: ``BASE_URL + /api/v1/slides/:id``

* **Method:** `DELETE`

* **Success Response:**
 ```json
{
  "message": "Successfully delete slider with id #{params[:id]}",
  "status_code": 200
}
```
* **Code:** `200`
* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          {
                "message": "Unable to find slider with ID",
                "status_code": 422
          }
         ```
