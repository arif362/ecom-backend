### Audit Logs
___

* **URL :** `BASE_URL + /api/v1/audit_logs`

* **Method :** `GET`

* **URL Params :**

```json
{
  "auditable_type": "Product",
  "auditable_id": 4034,
  "action": "create"
}
```
> **Values of action** ->
> create update destroy

> **Values of auditable_type** ->
> Brand Category Coupon CustomerOrder DhPurchaseOrder Product Promotion
ReturnTransferOrder Supplier SuppliersVariant Variant WhPurchaseOrder Rider Partner RetailerAssistant SalesRepresentative
Route Article AttributeSet AttributeSetProductAttribute
BankAccount BankTransaction BlockedItem Box
Campaign Challan Distributor DistributorMargin District FailedQc HelpTopic
Location MetaDatum PartnerMargin ProductAttribute
ProductCategory ProductFeature ProductType ProductsProductType PromoBanner PromoCoupon
PromotionVariant PurchaseOrderStatus ReturnChallan
ReturnCustomerOrder ReturnStatusChange Route RouteDevice
Slide SocialLink UserModificationRequest
UserModifyReason WarehouseBundle WarehouseVariant
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
            "id": 595413,
            "action": "update",
            "created_by": {
                "id": 189,
                "first_name": "CWH Script",
                "last_name": "Admin",
                "email": "cwh_script@agami.ltd",
                "staff_role_id": 1,
                "warehouse_id": 4,
                "created_at": "2022-08-07T20:27:50.268+06:00",
                "updated_at": "2022-08-07T20:27:50.268+06:00",
                "address_line": null,
                "unit": "fulfilment_center",
                "is_active": true,
                "staffable_id": 4,
                "staffable_type": "Warehouse"
            },
            "created_at": "2022-10-24T01:15:27.362+06:00",
            "audited_changes": {
                "slug": [
                    "bd-spicy-toast-biscuits-45gm",
                    "bd-spicy-toast-biscuits-45gm12345"
                ],
                "updated_at": [
                    "2022-10-24T00:38:53.807+06:00",
                    "2022-10-24T01:15:27.358+06:00"
                ]
            }
        },
        {
            "id": 595410,
            "action": "update",
            "created_by": {
                "id": 189,
                "first_name": "CWH Script",
                "last_name": "Admin",
                "email": "cwh_script@agami.ltd",
                "staff_role_id": 1,
                "warehouse_id": 4,
                "created_at": "2022-08-07T20:27:50.268+06:00",
                "updated_at": "2022-08-07T20:27:50.268+06:00",
                "address_line": null,
                "unit": "fulfilment_center",
                "is_active": true,
                "staffable_id": 4,
                "staffable_type": "Warehouse"
            },
            "created_at": "2022-10-24T00:38:53.819+06:00",
            "audited_changes": {
                "title": [
                    "BD Spicy Toast Biscuits 45gm",
                    "BD Spicy Toast Biscuits 45gm test"
                ],
                "bn_title": [
                    null,
                    ""
                ],
                "description": [
                    null,
                    ""
                ],
                "short_description": [
                    null,
                    ""
                ],
                "bn_short_description": [
                    null,
                    ""
                ],
                "warranty_period": [
                    null,
                    ""
                ],
                "warranty_policy": [
                    null,
                    ""
                ],
                "bn_warranty_policy": [
                    null,
                    ""
                ],
                "inside_box": [
                    null,
                    ""
                ],
                "bn_inside_box": [
                    null,
                    ""
                ],
                "video_url": [
                    null,
                    ""
                ],
                "dangerous_goods": [
                    null,
                    ""
                ],
                "certification": [
                    null,
                    ""
                ],
                "bn_certification": [
                    null,
                    ""
                ],
                "license_required": [
                    null,
                    ""
                ],
                "material": [
                    null,
                    ""
                ],
                "bn_material": [
                    null,
                    ""
                ],
                "bn_broad_description": [
                    null,
                    ""
                ],
                "consumption_guidelines": [
                    null,
                    ""
                ],
                "bn_consumption_guidelines": [
                    null,
                    ""
                ],
                "keywords": [
                    null,
                    ""
                ],
                "tagline": [
                    null,
                    ""
                ]
            }
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
   "message": "Unable to fetch customer order details",
   "data": {}
}
```

> ** Details of Audit log** ->

* **Method :** `GET`

* **URL Params : {id}**
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
    "success": true,
    "status": 200,
    "message": "Successfully fetched audit log",
    "data": {
        "id": 595415,
        "action": "update",
        "created_by": {
            "id": 189,
            "first_name": "CWH Script",
            "last_name": "Admin",
            "email": "cwh_script@agami.ltd",
            "staff_role_id": 1,
            "warehouse_id": 4,
            "created_at": "2022-08-07T20:27:50.268+06:00",
            "updated_at": "2022-08-07T20:27:50.268+06:00",
            "address_line": null,
            "unit": "fulfilment_center",
            "is_active": true,
            "staffable_id": 4,
            "staffable_type": "Warehouse"
        },
        "created_at": "2022-10-24T12:35:23.027+06:00",
        "audited_changes": {
            "price_consumer": [
                "10.0",
                "90.0"
            ],
            "effective_mrp": [
                "10.0",
                "90.0"
            ],
            "price_distribution": [
                "10.0",
                "90.0"
            ],
            "price_retailer": [
                "10.0",
                "90.0"
            ],
            "price_agami_trade": [
                "10.0",
                "90.0"
            ]
        }
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
   "message": "Unable to fetch customer order details",
   "data": {}
}
```


