**Bundle API's**
----

## Pack Bundle Product

* **URL**: ``BASE_URL + /api/v1/bundles/pack``

* **Method:** `POST`
* **Authentication:** `admin(staff)`
* **URL Params:**

```
params do
  requires :bundle_variant_id, type: Integer
  requires :bundle_location_id, type: Integer
  requires :bundle_quantity, type: Integer
  requires :bundle_variants, type: Array do
    requires :variant_id, type: Integer
    requires :packed_quantity, type: Integer
    requires :location_id, type: Integer
    requires :qr_code, type: String
  end
end
```

* **Success Response:**
* **Code:** `200`

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully packed bundle product.",
  "data": {}
}
```

* **Code:** `403`
* **Error Response:**
    * **Code:** `403`
    * **Content:**

 ```json
{
  "success": false,
  "status": 403,
  "message": "Unable to pack bundle variant",
  "data": {}
}
```

## Un-Pack Bundle Product

* **URL**: ``BASE_URL + /api/v1/bundles/un_pack``

* **Method:** `POST`
* **Authentication:** `admin(staff)`
* **URL Params:**

```
params do
  requires :bundle_variant_id, type: Integer
  requires :bundle_location_id, type: Integer
  requires :bundle_quantity, type: Integer
  requires :bundle_variants, type: Array do
    requires :variant_id, type: Integer
    requires :packed_quantity, type: Integer
    requires :location_id, type: Integer
    requires :qr_code, type: String
  end
end
```

* **Success Response:**
* **Code:** `200`

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully unpacked bundle product.",
  "data": {}
}
```

* **Code:** `403`
* **Error Response:**
  * **Code:** `403`
  * **Content:**

 ```json
{
  "success": false,
  "status": 403,
  "message": "Unable to unpacked this variant",
  "data": {}
}
```
