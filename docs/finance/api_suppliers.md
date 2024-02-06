### List of Suppliers for finance
___
* **URL :** `BASE_URL + finance/api/v1/suppliers`
* **Method :** `GET`
* **Headers :** `Auth_token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id":108,
    "supplier_name":"ACI Thanos",
    "phone":null,
    "mou_document_number":null,
    "supplier_representative":null,
    "representative_designation":null,
    "representative_contact":null,
    "tin":null,
    "bin":null,
    "contract_start_date":null,
    "contract_end_date":null,
    "agami_kam_contact":null,
    "agami_kam_email":null,
    "email":"admin11@shopoth.com"
  },
  {
    "id":107,
    "supplier_name":"MGH Supplier",
    "phone":null,
    "mou_document_number":null,
    "supplier_representative":null,
    "representative_designation":null,
    "representative_contact":null,
    "tin":null,
    "bin":null,
    "contract_start_date":null,
    "contract_end_date":null,
    "agami_kam_contact":null,
    "agami_kam_email":null,
    "email":"Supplier@misfit.tech"
  }
]

 ```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Suppliers not found.",
  "status_code": 404
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to fetch Supplier list.",
  "status_code": 422
}
```
### List of Suppliers for finance
___
* **URL :** `BASE_URL + finance/api/v1/suppliers/:id/suppliers_variants`
* **Method :** `GET`
* **Headers :** `Auth_token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "product": "ACI Sandal Soap",
    "variants": [
      {
        "id": 3254,
        "name": "HABIJABI-001",
        "sp_price": "63.0",
        "product_attribute_values": []
      }
    ]
  }
]
 ```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "message": "Suppliers not found.",
  "status_code": 404
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to fetch Supplier list.",
  "status_code": 422
}
```


