### Attribute Set List
___

* **URL :** `BASE_URL + /api/v1/attribute_sets`
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
  "message": "Successfully fetched all attribute sets",
  "data": [
    {
      "id": 7,
      "title": "color",
      "created_by_id": null,
      "unique_id": "044bb358-a3d5-4150-920d-b9be5d6dab3f",
      "product_attributes": [
        {
          "id": 44,
          "name": "Memory",
          "bn_name": "Memory",
          "is_deleted": false,
          "created_by_id": null,
          "unique_id": "239dd6af-d12c-4841-85fc-a07c1341dd35",
          "product_attribute_values": [
            {
              "id": 139,
              "product_attribute_id": 44,
              "value": "1 GB",
              "bn_value": "1 GB ",
              "is_deleted": false,
              "unique_id": "43f78600-14fb-48a9-ac16-b49741c09c2b"
            }
          ]
        },
        {
          "id": 43,
          "name": "red",
          "bn_name": "xcd",
          "is_deleted": false,
          "created_by_id": null,
          "unique_id": "55742dcc-6d04-4d16-b5c0-44b6bfbcb438",
          "product_attribute_values": [
            {
              "id": 135,
              "product_attribute_id": 43,
              "value": "a ",
              "bn_value": "d",
              "is_deleted": false,
              "unique_id": "a8dab601-71a4-4507-9b75-178f4ee77d08"
            }
          ]
        }
      ]
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
   "message": "Unable to find records due to #{error}",
   "data": {}
}
```
### Attribute Set Details
___

* **URL :** `BASE_URL + /api/v1/attribute_sets/:id`
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
  "message": "Successfully fetched attribute set",
  "data": {
    "id": 5,
    "title": "Taste",
    "created_by_id": null,
    "unique_id": "1192fc0f-33ad-4d18-8b63-8c98ee5bce5c",
    "product_attributes": [
      {
        "id": 38,
        "name": "Flavour",
        "bn_name": "Flavour bn",
        "is_deleted": false,
        "created_by_id": null,
        "unique_id": "e64af48c-f458-4c1b-9efa-b6ddec8c1774",
        "product_attribute_values": [
          {
            "id": 123,
            "product_attribute_id": 38,
            "value": "sweet",
            "bn_value": "মিষ্টি",
            "is_deleted": false,
            "unique_id": "eadbf8a4-0d31-496c-bc53-92db9a9691ad"
          },
          {
            "id": 124,
            "product_attribute_id": 38,
            "value": "sour",
            "bn_value": "টক",
            "is_deleted": false,
            "unique_id": "8e6d3b83-e5da-4304-bf19-2eb642efe576"
          }
        ]
      }
    ]
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
   "message": "Unable to find record due to #{error}",
   "data": {}
}
```
### Create Attribute Set
___

* **URL :** `BASE_URL + /api/v1/attribute_sets`
* **Method :** `POST`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "title": "Element Set",
  "product_attribute_ids": [
    53,
    50
  ]
}
```
* **Success Response**
* **Code :**`201`
* **Content :**
```json
{
  "success":true,
  "status":201,
  "message":"Successfully created attribute set",
  "data":{
    "id":431,
    "title":"Element Set",
    "created_by_id":108,
    "unique_id":"28d1e7d7-7bc9-4ed3-a773-88f5b120267d",
    "product_attributes":[
      {
        "id":53,
        "name":"Flower",
        "bn_name":"flower bn",
        "is_deleted":false,
        "created_by_id":null,
        "unique_id":"353f0722-5031-47cb-88ea-53375a762ce3",
        "product_attribute_values":[
          {"id":169,
            "product_attribute_id":53,
            "value":"Rose",
            "bn_value":"গোলাপ",
            "is_deleted":false,
            "unique_id":"6fdec4b8-c329-4512-bbe7-b11fa60e47aa"
          },
          {
            "id":171,
            "product_attribute_id":53,
            "value":"Lavander",
            "bn_value":"ল্যাভেন্ডার",
            "is_deleted":false,
            "unique_id":"86c094e4-31ca-4772-baa7-d58a0fc4d980"
          }
        ]
      }
    ]
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
   "message": "Cannot create attribute set due to #{error.message}",
   "data": {}
}
```
### Update Attribute Set
___

* **URL :** `BASE_URL + /api/v1/attribute_sets/:id`
* **Method :** `PUT`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "title": "Element Set Updated",
  "product_attribute_ids": [
    53,
    50
  ]
}
```
* **Success Response**
* **Code :**`201`
* **Content :**
```json
{
  "success":true,
  "status":201,
  "message":"Successfully updated attribute set",
  "data":{
    "id":431,
    "title":"Element Set Updated",
    "created_by_id":108,
    "unique_id":"28d1e7d7-7bc9-4ed3-a773-88f5b120267d",
    "product_attributes":[
      {
        "id":53,
        "name":"Flower",
        "bn_name":"flower bn",
        "is_deleted":false,
        "created_by_id":null,
        "unique_id":"353f0722-5031-47cb-88ea-53375a762ce3",
        "product_attribute_values":[
          {"id":169,
            "product_attribute_id":53,
            "value":"Rose",
            "bn_value":"গোলাপ",
            "is_deleted":false,
            "unique_id":"6fdec4b8-c329-4512-bbe7-b11fa60e47aa"
          },
          {
            "id":171,
            "product_attribute_id":53,
            "value":"Lavander",
            "bn_value":"ল্যাভেন্ডার",
            "is_deleted":false,
            "unique_id":"86c094e4-31ca-4772-baa7-d58a0fc4d980"
          }
        ]
      }
    ]
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
   "message": "Cannot update attribute set due to #{error.message}",
   "data": {}
}
```
### Delete Attribute Set
___

* **URL :** `BASE_URL + /api/v1/attribute_sets/:id`
* **Method :** `DELETE`
* **Header :** `Auth Token`
* **URL Params :**

```json
{
  "title": "Element Set Updated",
  "product_attribute_ids": [
    53,
    50
  ]
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "success":true,
  "status":200,
  "message":"Successfully deleted attribute set",
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
   "message": "Cannot delete attribute set due to #{error.message}",
   "data": {}
}
```
