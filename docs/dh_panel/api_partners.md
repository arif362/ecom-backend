**Partner APIs**
----

### Get all partners on DH panel:

* **URL**: ``BASE_URL + /distributor/api/v1/partners``
* **Method:** `GET`
* **Authorization:** `DH admin`
* **Params:**

```json 
  ```

* **Success Response:**

```json 
{
    "success": true,
    "status": 200,
    "message": "Successfully fetched partners.",
    "data": [
        {
            "id": 35,
            "name": "test partner",
            "phone": "0197653234",
            "order_count": 1223,
            "margin_amount": 9872761,
            "margin_received_by_partner": 7826,
            "route_title": "Test route",
            "sr_name": "test route name",
            "distributor_name": "Test distributor name",
            "region_name": "bd"
        }
    ]
}
  ```

* **Error Response:**
* **Code:** `200`
* **Content:**

```json 
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch partners.",
  "data": {}
}
  ```

### Get a specific partner details for DH panel:

* **URL**: ``BASE_URL + /distributor/api/v1/partners/567``
* **Method:** `GET`
* **Authorization:** `DH admin`
* **Params:**

```json 
  ```

* **Success Response:**

```json 
{
    "success": true,
    "status": 200,
    "message": "Successfully fetched partner details.",
    "data": {
        "id": 567,
        "route": {
            "id": 144,
            "title": "Central_Office_Pickup",
            "bn_title": "Central_Office_Pickup",
            "phone": "0138146134",
            "warehouse_id": 7,
            "created_at": "2021-07-14T16:34:14.612+06:00",
            "updated_at": "2022-07-23T13:15:00.430+06:00",
            "cash_amount": "8944697.0",
            "digital_amount": "0.0",
            "sr_point": "Central warehouse",
            "sr_name": "Robot",
            "distributor_id": 26
        },
        "name": "B2B_Sales_MBR",
        "phone": "01830101029",
        "image": null,
        "email": null,
        "password_presence": true,
        "status": "active",
        "schedule": "sat_sun_mon_tues_wed_thurs",
        "tsa_id": null,
        "retailer_code": null,
        "partner_code": "MBR_FC_B2B Sales",
        "region": "Shopoth_B2B",
        "area": null,
        "territory": "Shopoth_B2B",
        "point": null,
        "owner_name": null,
        "cluster_name": null,
        "sub_channel": null,
        "bn_name": "বি টু বি সেলস মেম্বার",
        "latitude": null,
        "longitude": null,
        "work_days": [
            {
                "is_opened": false
            },
            {
                "is_opened": false
            },
            {
                "is_opened": false
            },
            {
                "is_opened": false
            },
            {
                "is_opened": false
            },
            {
                "is_opened": false
            },
            {
                "is_opened": false
            }
        ],
        "slug": "b2b_sales_cwh",
        "is_commission_applicable": false,
        "due_payment": 17262808,
        "addresses": {
            "id": 955,
            "area_id": 274,
            "area_name": "Banani",
            "thana_id": 31,
            "thana_name": "Banani",
            "district_id": 5,
            "district_name": "Dhaka-Member",
            "name": "B2B Sales",
            "address_line": "H-41, R-4, Block-F, Banani, Dhaka-1212",
            "bn_address_line": null,
            "phone": "01810100072",
            "post_code": null
        },
        "meta_info": null,
        "distributor_name": "Salahuddin rakib"
    }
}
  ```

* **Code:** `200`
* **Error Response:**
* **Code:** `422`
* **Content:**

```json 
{
  "success": false,
  "status": 200,
  "message": "Unable to fetch partner details.",
  "data": {}
}
  ```

### Get partner's completed orders for DH panel:

* **URL**: ``BASE_URL + /distributor/api/v1/partners/567/completed_orders``
* **Method:** `GET`
* **Authorization:** `DH admin`
* **Params:**

```json 
{
"month": 5,
"year": 2022,
}
  ```

* **Success Response:**

```json 
{
    "success": true,
    "status": 200,
    "message": "Successfully fetched completed orders.",
    "data": [
        {
            "order_id": 73635,
            "order_at": "2022-05-23T16:27:45.375+06:00",
            "delivery_date": "2022-05-24T00:00:00.000+06:00",
            "order_type": "induced",
            "pay_type": "cash_on_delivery",
            "shipping_type": "pick_up_point",
            "status": "Completed",
            "price": "4100.0",
            "partner_margin": "0.0"
        }
    ]
}
  ```

* **Code:** `200`
* **Error Response:**
* **Code:** `422`
* **Content:**

```json 
{
  "success": false,
  "status": 200,
  "message": "Unable to fetch completed orders.",
  "data": {}
}
  ```
