**Promo Coupon API's**
----

## Create PromoCoupon

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons``

* **Method:** `POST`
* **Authentication:** `admin(staff)`
* **URL Params:**

```
params do
  requires :promo_coupon, type: Hash do
    requires :status, type: Integer
    requires :order_type, type: Integer
    requires :discount_type, type: Integer
    requires :start_date, type: DateTime
    requires :end_date, type: DateTime
    requires :number_of_coupon, type: Integer
    optional :minimum_cart_value, type: Float
    optional :discount, type: Float
    optional :max_discount_amount, type: Float
    optional :promo_coupon_rules_attributes, type: Array do
      requires :ruleable_type, type: String
      requires :ruleable_id, type: Integer
    end
  end
```

* **Success Response:**
* **Code:** `201`

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully Fetch PromoCoupon.",
  "data": {
    "id": 23,
    "status": "active",
    "status_key": 0,
    "start_date": "2022-02-10T06:00:00.000+06:00",
    "end_date": "2022-03-10T06:00:00.000+06:00",
    "minimum_cart_value": 300.0,
    "discount": 100.0,
    "max_discount_amount": null,
    "order_type": "both",
    "order_type_key": 0,
    "discount_type": "fixed",
    "discount_type_key": 0,
    "promo_coupon_rules": [
      {
        "ruleable_type": "Brand",
        "ruleable_values": [
          "Ongkur"
        ]
      },
      {
        "ruleable_type": "Warehouse",
        "ruleable_values": [
          "Central"
        ]
      }
    ]
  }
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Unable to create PromoCoupon. error: #{error}",
  "data": {}
}
```

## Update  PromoCoupon

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons/:id``

* **Method:** `PUT`
* **Authentication:** `admin(staff)`
* **URL Params:**

```
params do
  requires :promo_coupon, type: Hash do
        requires :title, type: String
        requires :status, type: Integer
        requires :start_date, type: DateTime
        requires :end_date, type: DateTime
  end
end
```

* **Success Response:**
* **Code:** `200`

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully Update PromoCoupon.",
  "data": {
    "id": 3,
    "status": "active",
    "status_key": 0,
    "start_date": "2022-02-10T06:00:00.000+06:00",
    "end_date": "2022-03-10T06:00:00.000+06:00",
    "minimum_cart_value": 300.0,
    "discount": 100.0,
    "max_discount_amount": 100.0,
    "order_type": "both",
    "order_type_key": 0,
    "discount_type": "fixed",
    "discount_type_key": 0,
    "promo_coupon_rules": [
      {
        "ruleable_type": "Brand",
        "ruleable_values": [
          "Ongkur"
        ]
      },
      {
        "ruleable_type": "Warehouse",
        "ruleable_values": [
          "Central"
        ]
      }
    ]
  }
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Unable to Update PromoCoupon. error: #{error}",
  "data": {}
}
```

## Fetch A  PromoCoupon

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons/:id``

* **Method:** `GET`
* **Authentication:** `admin(staff)`
* **URL Params:** ``none``

* **Success Response:**
* **Code:** `200`

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully Fetch PromoCoupon.",
  "data": {
    "id": 3,
    "title": " promo coupon for eid",
    "status": "active",
    "status_key": 0,
    "start_date": "2022-02-10T06:00:00.000+06:00",
    "end_date": "2022-03-10T06:00:00.000+06:00",
    "minimum_cart_value": 300.0,
    "discount": 100.0,
    "max_discount_amount": 100.0,
    "order_type": "both",
    "order_type_key": 0,
    "discount_type": "fixed",
    "discount_type_key": 0,
    "promo_coupon_rules": [
      {
        "ruleable_type": "Brand",
        "ruleable_values": [
          "Ongkur"
        ]
      },
      {
        "ruleable_type": "Warehouse",
        "ruleable_values": [
          "Central"
        ]
      }
    ]
  }
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Unable to Fetched PromoCoupon. error: ",
  "data": {}
}
```

## Fetch The List of PromoCoupon

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons``

* **Method:** `GET`
* **Authentication:** `admin(staff)`
* **URL Params:** ``none``

* **Success Response:**
* **Code:** `200`

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetch the list of promo_coupon.",
  "data": [
    {
      "id": 1,
      "status": "active",
      "start_date": "2022-02-10T06:00:00.000+06:00",
      "order_type": "both",
      "end_date": "2022-03-10T06:00:00.000+06:00",
      "minimum_cart_value": 300.0,
      "discount": 100.0,
      "max_discount_amount": 100.0,
      "discount_type": "fixed",
      "is_deleted": null,
      "created_at": "2022-03-28T11:42:09.940+06:00",
      "updated_at": "2022-03-28T11:42:09.940+06:00",
      "usable_count": 1,
      "usable_count_per_person": 1,
      "number_of_coupon": null,
      "title": "Promo Coupon 1"
    },
    {
      "id": 2,
      "status": "active",
      "start_date": "2022-02-10T06:00:00.000+06:00",
      "order_type": "both",
      "end_date": "2022-03-10T06:00:00.000+06:00",
      "minimum_cart_value": 300.0,
      "discount": 100.0,
      "max_discount_amount": 100.0,
      "discount_type": "fixed",
      "is_deleted": null,
      "created_at": "2022-03-28T11:50:32.997+06:00",
      "updated_at": "2022-03-28T11:50:32.997+06:00",
      "usable_count": 1,
      "usable_count_per_person": 1,
      "number_of_coupon": null,
      "title": "Promo Coupon 2"
    },
    {
      "id": 3,
      "status": "active",
      "start_date": "2022-02-10T06:00:00.000+06:00",
      "order_type": "both",
      "end_date": "2022-03-10T06:00:00.000+06:00",
      "minimum_cart_value": 300.0,
      "discount": 100.0,
      "max_discount_amount": 100.0,
      "discount_type": "fixed",
      "is_deleted": null,
      "created_at": "2022-03-28T11:53:41.480+06:00",
      "updated_at": "2022-03-28T11:53:41.480+06:00",
      "usable_count": 1,
      "usable_count_per_person": 1,
      "number_of_coupon": null,
      "title": "Promo Coupon 3"
    },
    {
      "id": 4,
      "status": "active",
      "start_date": "2022-02-10T06:00:00.000+06:00",
      "order_type": "both",
      "end_date": "2022-03-10T06:00:00.000+06:00",
      "minimum_cart_value": 300.0,
      "discount": 100.0,
      "max_discount_amount": 100.0,
      "discount_type": "fixed",
      "is_deleted": null,
      "created_at": "2022-03-28T12:22:54.388+06:00",
      "updated_at": "2022-03-28T12:22:54.388+06:00",
      "usable_count": 1,
      "usable_count_per_person": 1,
      "number_of_coupon": null,
      "title": "Promo Coupon 4"
    },
    {
      "id": 5,
      "status": "active",
      "start_date": "2022-02-10T06:00:00.000+06:00",
      "order_type": "both",
      "end_date": "2022-03-10T06:00:00.000+06:00",
      "minimum_cart_value": 300.0,
      "discount": 100.0,
      "max_discount_amount": 100.0,
      "discount_type": "fixed",
      "is_deleted": null,
      "created_at": "2022-03-28T12:49:21.034+06:00",
      "updated_at": "2022-03-28T12:49:21.034+06:00",
      "usable_count": 1,
      "usable_count_per_person": 1,
      "number_of_coupon": null,
      "title": "Promo Coupon 5"
    },
    {
      "id": 6,
      "status": "active",
      "start_date": "2022-02-10T06:00:00.000+06:00",
      "order_type": "both",
      "end_date": "2022-03-10T06:00:00.000+06:00",
      "minimum_cart_value": 300.0,
      "discount": 100.0,
      "max_discount_amount": 100.0,
      "discount_type": "fixed",
      "is_deleted": null,
      "created_at": "2022-03-28T12:53:33.283+06:00",
      "updated_at": "2022-03-28T12:53:33.283+06:00",
      "usable_count": 1,
      "usable_count_per_person": 1,
      "number_of_coupon": null,
      "title": "Promo Coupon 6"
    },
    {
      "id": 7,
      "status": "active",
      "start_date": "2022-02-10T06:00:00.000+06:00",
      "order_type": "both",
      "end_date": "2022-03-10T06:00:00.000+06:00",
      "minimum_cart_value": 300.0,
      "discount": 100.0,
      "max_discount_amount": 100.0,
      "discount_type": "fixed",
      "is_deleted": null,
      "created_at": "2022-03-28T13:06:11.196+06:00",
      "updated_at": "2022-03-28T13:06:11.196+06:00",
      "usable_count": 1,
      "usable_count_per_person": 1,
      "number_of_coupon": null,
      "title": null
    },
    {
      "id": 8,
      "status": "active",
      "start_date": "2022-02-10T06:00:00.000+06:00",
      "order_type": "both",
      "end_date": "2022-03-10T06:00:00.000+06:00",
      "minimum_cart_value": 300.0,
      "discount": 100.0,
      "max_discount_amount": 100.0,
      "discount_type": "fixed",
      "is_deleted": null,
      "created_at": "2022-03-28T13:06:56.240+06:00",
      "updated_at": "2022-03-28T13:06:56.240+06:00",
      "usable_count": 1,
      "usable_count_per_person": 1,
      "number_of_coupon": null,
      "title": null
    },
    {
      "id": 9,
      "status": "active",
      "start_date": "2022-02-10T06:00:00.000+06:00",
      "order_type": "both",
      "end_date": "2022-03-10T06:00:00.000+06:00",
      "minimum_cart_value": 300.0,
      "discount": 100.0,
      "max_discount_amount": 100.0,
      "discount_type": "fixed",
      "is_deleted": false,
      "created_at": "2022-03-28T19:52:20.624+06:00",
      "updated_at": "2022-03-28T19:52:20.624+06:00",
      "usable_count": 1,
      "usable_count_per_person": 1,
      "number_of_coupon": 7,
      "title": null
    },
    {
      "id": 10,
      "status": "active",
      "start_date": "2022-02-10T06:00:00.000+06:00",
      "order_type": "both",
      "end_date": "2022-03-10T06:00:00.000+06:00",
      "minimum_cart_value": 300.0,
      "discount": 100.0,
      "max_discount_amount": null,
      "discount_type": "fixed",
      "is_deleted": false,
      "created_at": "2022-03-29T15:37:17.756+06:00",
      "updated_at": "2022-03-29T15:37:17.756+06:00",
      "usable_count": 1,
      "usable_count_per_person": 1,
      "number_of_coupon": 7,
      "title": null
    }
  ]
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Something went wrong due to #{error}",
  "data": {}
}
```

## list of enum Status

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons/statuses``

* **Method:** `GET`
* **Authentication:** `admin(staff)`
* **URL Params:** `None`

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetch the list of status.",
  "data": [
    {
      "title": "Active",
      "value": 1
    },
    {
      "title": "Inactive",
      "value": 0
    }
  ]
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Something went wrong due to #{error}",
  "data": {}
}
```

## list of enum discount_types

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons/discount_types``

* **Method:** `GET`
* **Authentication:** `admin(staff)`
* **URL Params:** `None`

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetch the list of discount_type.",
  "data": [
    {
      "title": "Percentage",
      "value": 1
    },
    {
      "title": "Fixed",
      "value": 0
    }
  ]
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Something went wrong due to #{error}",
  "data": {}
}
```

## list of enum order_types

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons/order_types``

* **Method:** `GET`
* **Authentication:** `admin(staff)`
* **URL Params:** `None`

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetch the list of order_type.",
  "data": [
    {
      "title": "Both",
      "value": 0
    },
    {
      "title": "Induced",
      "value": 1
    },
    {
      "title": "Organic",
      "value": 2
    }
  ]
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Something went wrong due to #{error}",
  "data": {}
}
```

## list of ruleable_types

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons/ruleable_types``

* **Method:** `GET`
* **Authentication:** `admin(staff)`
* **URL Params:** `None`

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetch the list of ruleable_type.",
  "data": [
    {
      "title": "Sku",
      "value": "Variant"
    },
    {
      "title": "Brand",
      "value": "Brand"
    },
    {
      "title": "Category",
      "value": "Category"
    },
    {
      "title": "Customer",
      "value": "User"
    },
    {
      "title": "Outlet",
      "value": "Partner"
    },
    {
      "title": "Fc",
      "value": "Warehouse"
    },
    {
      "title": "District",
      "value": "District"
    },
    {
      "title": "Thana",
      "value": "Thana"
    },
    {
      "title": "Area",
      "value": "Area"
    }
  ]
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Something went wrong due to #{error}",
  "data": {}
}
```

## sku search

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons/search_by_sku``

* **Method:** `GET`
* **Authentication:** `admin(staff)`
* **URL Params:**

```
params do
  requires :sku, type: String
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully Search SKU.",
  "data": [
    {
      "id": 3120,
      "sku": "Nutella1"
    }
  ]
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Something went wrong due to #{error}",
  "data": {}
}
```

## search by title

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons/search_by_title``

* **Method:** `GET`
* **Authentication:** `admin(staff)`
* **URL Params:**

```
params do
  requires :type, type: String # [Brand/Category/Warehouse]
  requires :keyword, type: String
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully Search By Title.",
  "data": [
    {
      "id": 99,
      "name": "brand local 12"
    }
  ]
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Something went wrong due to #{error}",
  "data": {}
}
```

## search by title

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons/search_by_phone``

* **Method:** `GET`
* **Authentication:** `admin(staff)`
* **URL Params:**

```
params do
  requires :type, type: String # [User/Partner]
  requires :phone, type: String
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully Search By Phone.",
  "data": [
    {
      "id": 333,
      "phone": "01864935972",
      "full_name": "test"
    }
  ]
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Something went wrong due to #{error}",
  "data": {}
}
```

## Filter And Search

* **URL**: ``BASE_URL + /shop/api/v1/promo_coupons/filter_and_search``

* **Method:** `GET`
* **Authentication:** `admin(staff)`
* **URL Params:**

```
params do
  requires :type, type: String # [Warehouse/District/Thana]
  requires :id, type: String
  optional :keyword, type: String
end
```

* **Success Response:**

 ```json
{
  "success": true,
  "status": 200,
  "message": "Successfully Filter and Search",
  "data": [
    {
      "id": 3,
      "name": "Bogura"
    }
  ]
}
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `500`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Something went wrong due to #{error}",
  "data": {}
}
```

## Promo coupons export:

* **URL**: `BASE_URL + /api/v1/promo_coupons/:id/export`

* **Method:** `GET`
* **Authentication:** `admin(staff)`
* **URL Params:** `None`

* **Success Response:**

 ```json
[
  {
    "code": "992864",
    "applicable": {
      "applicable_on": [
        "RUPCHANDA"
      ],
      "applicable_for": [
        "Narsingdi FC"
      ]
    }
  },
  {
    "code": "843798",
    "applicable": {
      "applicable_on": [
        "RUPCHANDA"
      ],
      "applicable_for": [
        "Narsingdi FC"
      ]
    }
  }
]
```

* **Code:** `200`
* **Error Response:**
    * **Code:** `422`
    * **Content:**

 ```json
{
  "success": false,
  "status": 500,
  "message": "Unable to fetched coupon list of PromoCoupon.",
  "data": {}
}
```
