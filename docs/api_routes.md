**ROUTE and ROUTE_DEVICES API's**
----
***Create a route :*** First we need to create title, bn_title, phone, warehouse_id to create an route.


* **URL:** `BASE_URL + /api/v1/routes

* **Method:** `POST`

* **URL Params:**
`{
   "route": {
   "title": "mirpur 1",
   "bn_title": "mirpur 1",
   "phone": "018273763474",
   "distributor_id": 1,
   "sr_point": "", //optional
   "sr_name": "", //optional
   }
   }`
   
* **Success Response:**
 ```json
{
  "id": 9,
  "title": "mirpur 1",
  "bn_title": "mirpur 1",
  "phone": "018273763474",
  "distributor_id": 1,
  "sr_point": "",
  "sr_name": "",
}
```

Get a route

* **URL**: `BASE_URL + /api/v1/routes/:id

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
 {
  "id": 117,
  "title": "Hero Honda Route",
  "bn_title": "হিরো হোন্ডা রাউট ",
  "phone": "01818995776",
  "sr_name": "SR Honda",
  "sr_point": "SR Honda Store",
  "route_device": {},
  "distributor_name": null,
  "distributor_bn_name": null
}

```


Get routes partner export

* **URL**: `BASE_URL + /api/v1/route_margins/partners_export

* **Method:** `GET`

* **URL Params:**


* optional :title, type: String
* requires :distributor_id, type: Integer
* requires :month, type: Integer
* requires :year, type: Integer
* optional :partner_schedule, type: String

* **Success Response:**
 ```json
 [
  {
    "id": 145,
    "name": "Hero Honda Routee        ",
    "phone": "01817995776",
    "order_count": 0,
    "margin_amount": 0,
    "margin_received_by_partner": false,
    "route_title": "Hero Honda Route",
    "sr_name": "SR Honda",
    "distributor_name": null
  }
]
```

Get routes paginate

* **URL**: `BASE_URL + /api/v1/routes/paginate

* **Method:** `GET`

* **URL Params:**
  `{
  "per_page": 15,
  "page": 1,
  "distributor_id": 1,
  "title": "Rider",
  }
  `

* **Success Response:**
 ```json
 [
  {
    "id": 117,
    "title": "Hero Honda Route",
    "sr_name": "SR Honda",
    "sr_point": "SR Honda Store",
    "bn_title": "হিরো হোন্ডা রাউট ",
    "phone": "01818995776",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 116,
    "title": "Siam Routes",
    "sr_name": "Siam",
    "sr_point": "1",
    "bn_title": "হ্যালো",
    "phone": "01788628782",
    "cash_amount": "12000.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 112,
    "title": "Route-a",
    "sr_name": "Moshiur",
    "sr_point": "Moshiur SR",
    "bn_title": "Route-a",
    "phone": "01517816145",
    "cash_amount": "635.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 71,
    "title": "Route reconciliation testing",
    "sr_name": "Route reconciliation",
    "sr_point": "Route reconciliation",
    "bn_title": "Route reconciliation testing",
    "phone": "01967579586",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  }
]
```

Get all routes

* **URL**: `BASE_URL + /api/v1/routes

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
 
```

Get all routes

* **URL**: `BASE_URL + /api/v1/routes

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
 [
  {
    "id": 117,
    "title": "Hero Honda Route",
    "sr_name": "SR Honda",
    "sr_point": "SR Honda Store",
    "bn_title": "হিরো হোন্ডা রাউট ",
    "phone": "01818995776",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 116,
    "title": "Siam Routes",
    "sr_name": "Siam",
    "sr_point": "1",
    "bn_title": "হ্যালো",
    "phone": "01788628782",
    "cash_amount": "12000.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 112,
    "title": "Route-a",
    "sr_name": "Moshiur",
    "sr_point": "Moshiur SR",
    "bn_title": "Route-a",
    "phone": "01517816145",
    "cash_amount": "635.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 111,
    "title": "v2 Kill",
    "sr_name": "kill",
    "sr_point": "kill",
    "bn_title": "v2 Kill",
    "phone": "01558143505",
    "cash_amount": "3960.0",
    "total_order": 15,
    "due": "60918.0",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 110,
    "title": "banani dokan",
    "sr_name": "himi",
    "sr_point": "himi",
    "bn_title": "banani dokan",
    "phone": "01795758044",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 109,
    "title": "PradoLandCruiser",
    "sr_name": "PradoLandCruiser",
    "sr_point": "PradoLandCruiser",
    "bn_title": "PradoLandCruiser",
    "phone": "01741489134",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 106,
    "title": "prado router",
    "sr_name": "prado SR",
    "sr_point": "prado SR",
    "bn_title": "prado route",
    "phone": "01741489134",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 102,
    "title": "Mirpur",
    "sr_name": "Roksana",
    "sr_point": "1",
    "bn_title": "হ্যালো",
    "phone": "12345678909",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 101,
    "title": "Roksana",
    "sr_name": "Roksana",
    "sr_point": "1",
    "bn_title": "হ্যালো",
    "phone": "01670107644",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 99,
    "title": "asdfghjk",
    "sr_name": "asdfghjk",
    "sr_point": "asdfghjk",
    "bn_title": "werdtyu",
    "phone": "01674157022",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 98,
    "title": "asdfghjk",
    "sr_name": "sdfgh",
    "sr_point": "sdfghjkl",
    "bn_title": "asdfghjk",
    "phone": "+8801674157022",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 78,
    "title": "Product Quantity check route",
    "sr_name": "Pran's SR",
    "sr_point": "Narshindi",
    "bn_title": "Don't touch this route",
    "phone": "01967579586",
    "cash_amount": "83727.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 77,
    "title": "Sumaya route",
    "sr_name": "Sumaya route",
    "sr_point": "Sumaya route",
    "bn_title": "Sumaya route",
    "phone": "01712345678",
    "cash_amount": "9998.0",
    "total_order": 9,
    "due": "9141.0",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 75,
    "title": "new",
    "sr_name": "123456789",
    "sr_point": "new",
    "bn_title": "new",
    "phone": "123456789",
    "cash_amount": "30215.0",
    "total_order": 9,
    "due": "618.0",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 74,
    "title": "Nargis route",
    "sr_name": "Nargis ",
    "sr_point": "Nargis(dh)",
    "bn_title": "Nargis route",
    "phone": "01456987123",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": "test distributor",
    "distributor_bn_name": "bn test distributor"
  },
  {
    "id": 73,
    "title": "Partner testing",
    "sr_name": "0000",
    "sr_point": "0000",
    "bn_title": "Partner testing",
    "phone": "0000",
    "cash_amount": "6949.0",
    "total_order": 12,
    "due": "15550.0",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 72,
    "title": "Sumon",
    "sr_name": "Sumon",
    "sr_point": "Sumon",
    "bn_title": "সুমন",
    "phone": "01727212132",
    "cash_amount": "75052.0",
    "total_order": 18,
    "due": "29737.0",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 71,
    "title": "Route reconciliation testing",
    "sr_name": "Route reconciliation",
    "sr_point": "Route reconciliation",
    "bn_title": "Route reconciliation testing",
    "phone": "01967579586",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 68,
    "title": "route",
    "sr_name": "route",
    "sr_point": "route",
    "bn_title": "route",
    "phone": "123456",
    "cash_amount": "270.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 64,
    "title": "dont touch",
    "sr_name": "dont touch",
    "sr_point": "dont touch",
    "bn_title": "dont touch",
    "phone": "1111",
    "cash_amount": "-16854.0",
    "total_order": 3,
    "due": "9467.0",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 63,
    "title": "Banani",
    "sr_name": "nam jani na",
    "sr_point": "Jana nai",
    "bn_title": "Banani",
    "phone": "01795758044",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 60,
    "title": "rakib recon",
    "sr_name": "rakib recon",
    "sr_point": "rakib recon",
    "bn_title": "rakib recon",
    "phone": "0000",
    "cash_amount": "-64751.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 59,
    "title": "Khilgaon",
    "sr_name": "Roksana ",
    "sr_point": "2",
    "bn_title": "Khilgao",
    "phone": "01670107644",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 58,
    "title": "report & margin",
    "sr_name": "report & margin",
    "sr_point": "report & margin",
    "bn_title": "report & margin",
    "phone": "00",
    "cash_amount": "-3513.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 57,
    "title": "hh",
    "sr_name": "hh",
    "sr_point": "k",
    "bn_title": "jj",
    "phone": "01712047697",
    "cash_amount": "10245.0",
    "total_order": 1,
    "due": "2000.0",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 56,
    "title": "Sumaya SR",
    "sr_name": "sumaya SR",
    "sr_point": "Mirpur",
    "bn_title": "sumaya SR",
    "phone": "01712047697",
    "cash_amount": "124.0",
    "total_order": 16,
    "due": "5165.0",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 55,
    "title": "New partner changes",
    "sr_name": "New partner changes",
    "sr_point": "New partner changes",
    "bn_title": "New partner changes",
    "phone": "33",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 54,
    "title": "Report",
    "sr_name": "12",
    "sr_point": "12",
    "bn_title": "Report",
    "phone": "12",
    "cash_amount": "-120.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 53,
    "title": "Tuba",
    "sr_name": "Tuba",
    "sr_point": "tuba",
    "bn_title": "tuba",
    "phone": "01982273529",
    "cash_amount": "28655.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 52,
    "title": "nargis",
    "sr_name": "nargis",
    "sr_point": "nargis",
    "bn_title": "nargis",
    "phone": "2222",
    "cash_amount": "-135000.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 49,
    "title": "Induce",
    "sr_name": "Induce",
    "sr_point": "Induce",
    "bn_title": "Induce",
    "phone": "11",
    "cash_amount": "191.0",
    "total_order": 19,
    "due": "116046.1",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 48,
    "title": "bkash",
    "sr_name": "bkash",
    "sr_point": "bkash",
    "bn_title": "bkash",
    "phone": "00000000001",
    "cash_amount": "-171.0",
    "total_order": 2,
    "due": "7175.0",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 47,
    "title": "Mix",
    "sr_name": "Mix",
    "sr_point": "Mix",
    "bn_title": "Mix",
    "phone": "11",
    "cash_amount": "77.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 46,
    "title": "HIMI2",
    "sr_name": "HIMI2",
    "sr_point": "HIMI2",
    "bn_title": "HIMI2",
    "phone": "12345678",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 45,
    "title": "Monika",
    "sr_name": "Monika",
    "sr_point": "Monika",
    "bn_title": "Monika",
    "phone": "00",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 44,
    "title": "Arif",
    "sr_name": "Arif",
    "sr_point": "1234",
    "bn_title": "arif",
    "phone": "01914840253",
    "cash_amount": "0.0",
    "total_order": 1,
    "due": "588.0",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 43,
    "title": "himi test",
    "sr_name": "n/a",
    "sr_point": "n/a",
    "bn_title": "himi test",
    "phone": "1624681821",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 42,
    "title": "HIMI",
    "sr_name": "HIMI",
    "sr_point": "HIMI",
    "bn_title": "HIMI",
    "phone": "0000000000",
    "cash_amount": "15010.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 39,
    "title": "MONIKA",
    "sr_name": "Monika",
    "sr_point": "MONIKA",
    "bn_title": "MONIKA",
    "phone": "01681947040",
    "cash_amount": "127326.0",
    "total_order": 5,
    "due": "142638.0",
    "distributor_name": null,
    "distributor_bn_name": null
  },
  {
    "id": 36,
    "title": "title in eng",
    "sr_name": "asdf",
    "sr_point": "asdf",
    "bn_title": "title in ban",
    "phone": "1234567890",
    "cash_amount": "0.0",
    "total_order": 0,
    "due": 0,
    "distributor_name": null,
    "distributor_bn_name": null
  }
]
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```

***Create a route_device :*** First we need to create device_id, password, route_id, unique_id to create an route_device.


* **URL:** `BASE_URL + /api/v1/route_devices

* **Method:** `POST`

*  **URL Params:**
   `{
   "route_device": {
   "device_id": "734673",
   "route_id": "10"
   }
   }`

* **Success Response:**
 ```json
{
  "id": 11,
  "unique_id": "957130",
  "route": {
    "id": 10,
    "title": "mirpur 1",
    "bn_title": "mirpur 1",
    "phone": "018273763474",
    "warehouse_id": 1
  },
  "message": "share the pin with dh admin"
}
```

Get all route_devices

* **URL**: `BASE_URL + /api/v1/route_devices

* **Method:** `GET`

*  **URL Params:** `None`

* **Success Response:**
 ```json
 [
  {
    "id": 1,
    "device_id": "1",
    "route_id": 8,
    "unique_id": "1"
  },
  {
    "id": 2,
    "device_id": "1",
    "route_id": 1,
    "unique_id": "2"
  },
  {
    "id": 3,
    "device_id": "1",
    "route_id": null,
    "unique_id": "6"
  },
  {
    "id": 8,
    "device_id": "23232",
    "route_id": 1,
    "unique_id": "647122"
  },
  {
    "id": 7,
    "device_id": "23232",
    "route_id": 1,
    "unique_id": "23232"
  }
]
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
      ```
Update a route_device and change password 

* **URL**: `BASE_URL + /api/v1/route_devices/:id

* **Method:** `PUT`

*  **URL Params:** 
   `{
   "route_device": {
   "unique_id": "23232",
   "password": "212323"
   }
   }`

* **Success Response:**
 ```json
{
  "unique_id": "23232",
  "id": 7,
  "device_id": "23232",
  "route_id": 1
}
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```


Connect device

* **URL**: `BASE_URL + /api/v1/route_devices/:id/update

* **Method:** `PUT`

*  **URL Params:**
   `{
   "route_device": {
   "route_id": 1,
   "unique_id": "23232",
   "password": "111111"
   }
   }`

* **Success Response:**
 ```json
{
  "message": "Update Success!",
  "status_code": 200
}
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```
Disconnect device

* **URL**: `BASE_URL + /api/v1/route_devices/:id/disconnect

* **Method:** `PUT`

*  **URL Params:**
   `None`

* **Success Response:**
 ```json
{
  "message": "Disconect Success!",
  "status_code": 200
}
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```


         ```
Device Integration

* **URL**: `BASE_URL + /api/v1/route_devices

* **Method:** `POST`

*  **URL Params:**
   `{
   "device_id": "7"
   }`

* **Success Response:**
 ```json
{
  "connected": true,
  "route_title": "mirpur 1",
  "dh_name": "Dhaka"
}
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }
         ```

Route Setup

* **URL**: `BASE_URL + /api/v1/route_devices

* **Method:** `POST`

*  **URL Params:**
   `{
   "device_id": "100"
   }`

* **Success Response:**
 ```json
{
  "connected": false,
  "pin": "584082"
}
```

* **Error Response:**
    * **Code:** `422`
    * **Content:**
         ```json 
          { "message": "", "status_code":  }