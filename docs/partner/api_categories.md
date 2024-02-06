### Category wise brands list
___

* **URL :** `BASE_URL + partner/api/v1/category/:category_id/brands`

* **Method :** `GET`

* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  "Prado Brand",
  "fruits",
  "Test brand235",
  "New Testing"
]
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to fetch category products",
  "status_code": 422
}
```
