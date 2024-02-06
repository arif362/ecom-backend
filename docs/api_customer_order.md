**Customer Order's API (Ecom)**
----
Please make sure there are valid addresses + cart in the system to be 
assigned in 
the orders

* **URL**: ``BASE_URL + /shop/api/v1/customer_orders``

* **Method:** `POST`

*  **URL Params:**
   ```
   params do
          requires :cart_id, type: Integer
          requires :shipping_type, type: String
          optional :full_name, type: String
          optional :phone, type: String
          optional :new_address, type: Hash do
            requires :district_id, type: Integer
            requires :thana_id, type: Integer
            requires :area_id, type: Integer
            # Due to frontend requirement I had to take input full_name and phone twice (for pick_up_point and home_delivery and express_delivery) in the params.
            requires :full_name, type: String
            requires :phone, type: String
            requires :home_address, type: String
            optional :alternative_phone, type: String
            optional :post_code, type: Integer
            optional :title, type: String, default: 'others'
            optional :remember, type: Boolean
          end
          optional :partner_id, type: Integer
          optional :rider_id, type: Integer
          optional :billing_address_id, type: Integer
          optional :shipping_address_id, type: Integer
          requires :form_of_payment, type: String
          optional :domain, type: String
          optional :customer_device_id, type: Integer
        end
   ```

* **Success Response:**
 ```json
{
  "data": {
    "id": 4512, 
    "pay_type": "cash_on_delivery", 
    "total_price": "226.0"
  },
  "message": "Successfully created customer order.",
  "status": 200,
  "success": true
}
```

* **Code:** `201`
* **Error Response:**
    * **Code:** `422`, `500`
    * **Content:**
         ```json 
          { "message": "Can't process without valid addresses", 422 }
         ```
         ```json 
          { "message": "Something went wrong", 500 }
         ```   
