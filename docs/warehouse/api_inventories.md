### Return list of products.
___

* **URL :** `BASE_URL + /api/v1/inventories/products`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id": 11,
    "product_title": "T shirt",
    "sku": "229501",
    "trade_price": 0,
    "mrp": "0.0",
    "available_quantity": 0,
    "booked_quantity": 0,
    "blocked_quantity": 0,
    "packed_quantity": 0,
    "in_transit_quantity": 0,
    "in_partner_quantity": 0,
    "qc_quantity": 0,
    "total_count": 0,
    "distribution_margin": "0.0"
  },
  {
    "id": 46,
    "product_title": "Nokia 11001",
    "sku": "5676",
    "trade_price": 0,
    "mrp": "0.0",
    "available_quantity": 0,
    "booked_quantity": 0,
    "blocked_quantity": 0,
    "packed_quantity": 0,
    "in_transit_quantity": 0,
    "in_partner_quantity": 0,
    "qc_quantity": 0,
    "total_count": 0,
    "distribution_margin": "0.0"
  }
]
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "success": true,
  "status": 422,
  "message": "Unable to return products.",
  "data": {}
}
```
### Get distribution warehouse list
___

* **URL :** `BASE_URL + /api/v1/inventories/warehouses`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "warehouses":
  [
    {
      "id":55,
      "name":"Dhaka-B2B"
    },
    {
      "id":53,
      "name":"test warehouse"
    },
    {
      "id":52,
      "name":"Prado distribution"
    },
    {
      "id":51,
      "name":"Banani Distribution"
    },
    {
      "id":50,
      "name":"Misfit-Test"
    }
  ],
  "status":200
}
```
### Export products.
___

* **URL :** `BASE_URL + /api/v1/inventories/export`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id": 11,
    "product_title": "T shirt",
    "sku": "229501",
    "trade_price": 0,
    "mrp": "0.0",
    "available_quantity": 0,
    "booked_quantity": 0,
    "blocked_quantity": 0,
    "packed_quantity": 0,
    "in_transit_quantity": 0,
    "in_partner_quantity": 0,
    "qc_quantity": 0,
    "total_count": 0,
    "distribution_margin": "0.0"
  },
  {
    "id": 76,
    "product_title": "Remax headphone 500",
    "sku": "Remax headphone green 300",
    "trade_price": "1620.0",
    "mrp": "342.0",
    "available_quantity": 12,
    "booked_quantity": 0,
    "blocked_quantity": 8,
    "packed_quantity": 0,
    "in_transit_quantity": 0,
    "in_partner_quantity": 0,
    "qc_quantity": 6,
    "total_count": 18,
    "distribution_margin": "5.13"
  }
]
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to return product due to #{error.message}"
}
```
