### Purchase Order Create
___

* **URL :** `BASE_URL + /api/v1/purchase_orders`
* **Method :** `POST`
* **Header :** `Authorization: auth-token`
* **URL Params :**

```json
{
   "purchase_order": {
      "variants":[
         {
            "variant_id": 1, //integer
            "supplier_id": 10, //integer
            "quantity": 100, //integer
	    "unique_id": fc10b881-d9a0-4ab1-a6fd-a102db188f49, //string
	    "po_id": 1
         },
         {
            "variant_id": 2, //integer
            "supplier_id": 10, //integer
            "quantity": 10 //integer
	    "unique_id": fc10b881-d9a0-4ab1-a6fd-a102db188f48, //string
	    "po_id": 2
         }
      ]
   }
}

```
* **Success Response**
* **Code :**`201`
* **Content :**
```json
{
   "success": true,
   "status_code": 201,
   "message": "Successfully purchase order created",
   "data": {}
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "success": false,
   "status_code": 422,
   "message": "Unable to create purchase order",
   "data": {}
}
```
