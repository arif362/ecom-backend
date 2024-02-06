## Retailer Assistant API's
___
### Create Retailer Assistant

* **URL:** `BASE_URL + /api/v1/retailer_assistants`

* **Method:** `POST`

* **URL Params:**
```json
{
    "distributor_id": 7,
    "distributor_name": "M/S BARISHAL J AHMED & CO.",
    "name": "RA1",
    "phone":"01857123456",
    "email": null,
    "password":"123456",
    "password_confirmation": "123456",
    "category": "dedicated",
    "father_name": null,
    "experience": null,
    "education":null,
    "date_of_birth": null,
    "nid": null,
    "tech_skill": null,
    "address_attributes": {
        "area_id": 1,
        "address_line": "Area-1 block-A"
    }
}
```
* **Success Response**
  * **Code** :`201`
  * **Content :**
```json
{
  "success": true,
  "message": "Successfully created",
  "status_code": 201
}
```
* **Error Response:**
    * **Code :** `422`
    * **Content :**

 ```json
{
  "success": false,
  "status": 422,
  "message": "Unable to create retailer assistant.",
  "data": {}
}
```
### Retailer Assistant Details
___

* **URL :** `BASE_URL + /distributors/api/v1/retailer_assistants/:id`
* **Method :** `GET`
* **URL Params :**
* **Success Response**
  * **Code :**`200`
  * **Content :**
```json
{
    "success": true,
    "status": 200,
    "message": "Successfully fetched",
    "data": {
        "id": 387,
        "distributor_id": 7,
        "distributor_name": "M/S BARISHAL J AHMED & CO.",
        "name": "DWH RA Update Test 2",
        "phone": "0185xxxxx",
        "email": null,
        "father_name": null,
        "experience": null,
        "education": null,
        "category": "dedicated",
        "nid": null,
        "tech_skill": null,
        "date_of_birth": null,
        "address": {
            "address_line": "Area-1 block-A",
            "area_id": 1,
            "area_name": "Arongghata Bazar",
            "thana_id": 1,
            "thana_name": "Arongghata",
            "district_id": 1,
            "district_name": "Khulna"
        },
        "status": "active"
    }
}
```
* **Error Response**
  * **Code :**`422`
  * **Content :**
```json
{
  "success": false,
  "status": 404,
  "message": "Not found",
  "data": {}
}
```
### Retailer Assistant Update
___

* **URL :** `BASE_URL + /distributors/api/v1/retailer_assistants/:id`
* **Method :** `PUT`
* **URL Params :**

```json
{
    "name": "DWH RA Update Test 2",
    "distributor_id": 7
}
```
* **Success Response**
  * **Code :**`200`
  * **Content :**
```json
{
    "success": true,
    "status": 200,
    "message": "Successfully updated",
    "data": true
}
```
* **Error Response**
  * **Code :**`422`
  * **Content :**
```json
{
  "success": false,
  "status": 404,
  "message": "Not found",
  "data": {}
}
```
