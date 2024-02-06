### Get all slider filtered by image type.
___

* **URL :** `BASE_URL + /shop/api/v1/sliders`
* **Method :** `GET`
* **URL Params :**

```json
{
  "image_type": "homepage_slider"
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Slider fetched successfully.",
  "data": {
    "name": "1",
    "body": "Test",
    "link_url": "null",
    "position": 1,
    "img_type": "homepage_slider",
    "image": "http://cdn.shopoth.net/qhtg7i9tnc8pa6p4k849fytwvun2"
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
   "message": "Unable to fetch sliders",
   "data": {}
}
```
