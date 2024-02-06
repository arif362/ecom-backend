### Details of a specific line item with audit logs.
___

* **URL :** `BASE_URL + /api/v1/line_items/:id`
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
  "success": true,
  "status": 200,
  "message": "Successfully fetched audit log",
  "data": [
    {
      "id": 25847,
      "action": "create",
      "auditable_id": 2399,
      "auditable_type": "LineItem",
      "created_by": {
        "id": 108,
        "first_name": "Rukaiya",
        "last_name": "Central Admin",
        "email": "rukaiya@central.com",
        "staff_role_id": 1,
        "warehouse_id": 46,
        "created_at": "2022-08-30T10:28:27.245+06:00",
        "updated_at": "2022-08-30T10:28:27.245+06:00",
        "address_line": null,
        "unit": "central_warehouse",
        "is_active": true,
        "staffable_id": 46,
        "staffable_type": "Warehouse"
      },
      "created_at": "2022-12-22T18:54:13.438+06:00",
      "audited_changes": {
        "variant_id": 3194,
        "quantity": 1,
        "price": "33.0",
        "itemable_type": "WarehouseBundle",
        "itemable_id": 3,
        "received_quantity": 1,
        "qc_passed": 1,
        "qc_failed": 0,
        "qc_status": true,
        "location_id": 64,
        "remaining_quantity": 0,
        "reconcilation_status": [
          null,
          "closed"
        ],
        "qr_code": "",
        "send_quantity": 1,
        "settled_quantity": 0,
        "expiry_date": null,
        "location_code": [
          null,
          null
        ]
      }
    }
  ]
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "status_code": 404,
  "message": "Line item not found"
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "status_code": 404,
  "message": "Audit log not found"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Unable to fetch location audit log due to #{error.message}"
}
```
### create distribution house purchase order and assign it to line items
___

* **URL :** `BASE_URL + /api/v1/line_items/create_line_items_with_dh_po`
* **Method :** `POST`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "dh_order_params": {
    "variants": [
      {
        "variant_id": 2,
        "quantity": 10
      },
      {
        "variant_id": 3,
        "quantity": 10
      },
      {
        "variant_id": 5,
        "quantity": 10
      }
    ]
  }
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "dh_purchase_order": {
    "id": 782,
    "warehouse_id": 8,
    "order_by": null,
    "quantity": "30.0",
    "total_price": "479.7",
    "order_date": "2022-12-28T11:44:46.199+06:00",
    "is_deleted": false,
    "created_at": "2022-12-28T11:44:46.216+06:00",
    "updated_at": "2022-12-28T11:44:46.216+06:00",
    "order_status": "order_placed",
    "created_by_id": 81,
    "line_items": [
      {
        "id": 2400,
        "variant_id": 2,
        "quantity": 10,
        "price": "2.97",
        "itemable_type": "DhPurchaseOrder",
        "itemable_id": 782,
        "created_at": "2022-12-28T11:44:46.228+06:00",
        "updated_at": "2022-12-28T11:44:46.228+06:00",
        "received_quantity": 0,
        "qc_passed": 0,
        "qc_failed": 0,
        "qc_status": false,
        "location_id": null,
        "remaining_quantity": 0,
        "reconcilation_status": "closed",
        "qr_code": "",
        "send_quantity": 0,
        "settled_quantity": 0,
        "expiry_date": null,
        "product_id": 45,
        "product_title": "Electronics"
      },
      {
        "id": 2401,
        "variant_id": 3,
        "quantity": 10,
        "price": "22.0",
        "itemable_type": "DhPurchaseOrder",
        "itemable_id": 782,
        "created_at": "2022-12-28T11:44:46.241+06:00",
        "updated_at": "2022-12-28T11:44:46.241+06:00",
        "received_quantity": 0,
        "qc_passed": 0,
        "qc_failed": 0,
        "qc_status": false,
        "location_id": null,
        "remaining_quantity": 0,
        "reconcilation_status": "closed",
        "qr_code": "",
        "send_quantity": 0,
        "settled_quantity": 0,
        "expiry_date": null,
        "product_id": 2,
        "product_title": "RCA RFR320-B-Black-COM RFR321 Mini Refrigerator, 3.2 Cu Ft Fridge, Black, CU.FT"
      },
      {
        "id": 2402,
        "variant_id": 5,
        "quantity": 10,
        "price": "23.0",
        "itemable_type": "DhPurchaseOrder",
        "itemable_id": 782,
        "created_at": "2022-12-28T11:44:46.252+06:00",
        "updated_at": "2022-12-28T11:44:46.252+06:00",
        "received_quantity": 0,
        "qc_passed": 0,
        "qc_failed": 0,
        "qc_status": false,
        "location_id": null,
        "remaining_quantity": 0,
        "reconcilation_status": "closed",
        "qr_code": "",
        "send_quantity": 0,
        "settled_quantity": 0,
        "expiry_date": null,
        "product_id": 46,
        "product_title": "Electronics"
      }
    ]
  }
}
```
* **Error Response**
* **Code :**`403`
* **Content :**
```json
{
  "status_code": 403,
  "message": "Only FC can place STO"
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Unable to create line items due to: #{ex.message}."
}
```
