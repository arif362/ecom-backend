### Get distribution warehouse list
___

* **URL :** `BASE_URL + /api/v1/dashboard/stats/7/days`
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
  "order_type": {
    "data": [
      {
        "date": "21-12-2022",
        "organic": 0,
        "induced": 4
      },
      {
        "date": "22-12-2022",
        "organic": 1,
        "induced": 4
      },
      {
        "date": "23-12-2022",
        "organic": 0,
        "induced": 0
      },
      {
        "date": "24-12-2022",
        "organic": 0,
        "induced": 0
      },
      {
        "date": "25-12-2022",
        "organic": 0,
        "induced": 0
      },
      {
        "date": "26-12-2022",
        "organic": 0,
        "induced": 1
      },
      {
        "date": "27-12-2022",
        "organic": 0,
        "induced": 0
      }
    ],
    "total_order_in_7_days": 16,
    "x_axis": {
      "x1": "date"
    },
    "y_axis": {
      "y1": "organic",
      "y2": "induced"
    },
    "max_value": 4
  },
  "shipping_type": {
    "data": [
      {
        "date": "21-12-2022",
        "home": 0,
        "express": 0,
        "pick_up": 0
      },
      {
        "date": "22-12-2022",
        "home": 0,
        "express": 0,
        "pick_up": 0
      },
      {
        "date": "23-12-2022",
        "home": 0,
        "express": 0,
        "pick_up": 0
      },
      {
        "date": "24-12-2022",
        "home": 0,
        "express": 0,
        "pick_up": 0
      },
      {
        "date": "25-12-2022",
        "home": 0,
        "express": 0,
        "pick_up": 0
      },
      {
        "date": "26-12-2022",
        "home": 0,
        "express": 0,
        "pick_up": 0
      },
      {
        "date": "27-12-2022",
        "home": 0,
        "express": 0,
        "pick_up": 0
      }
    ],
    "total_order_in_7_days": 0,
    "x_axis": {
      "x1": "date"
    },
    "y_axis": {
      "y1": "home",
      "y2": "express",
      "y3": "pick_up"
    },
    "max_value": 0
  },
  "value_discount": {
    "data": [
      {
        "date": "21-12-2022",
        "price": "9276.0"
      },
      {
        "date": "22-12-2022",
        "price": "1683.0"
      },
      {
        "date": "23-12-2022",
        "price": 0
      },
      {
        "date": "24-12-2022",
        "price": 0
      },
      {
        "date": "25-12-2022",
        "price": 0
      },
      {
        "date": "26-12-2022",
        "price": "24000.0"
      },
      {
        "date": "27-12-2022",
        "price": 0
      }
    ],
    "total_order_in_7_days": 16,
    "y_axis": {
      "y1": "price"
    },
    "x_axis": {
      "x1": "date"
    },
    "max_value": "24000.0"
  },
  "cart_mrp": {
    "data": [
      {
        "date": "21-12-2022",
        "price": "9276.0"
      },
      {
        "date": "22-12-2022",
        "price": "1683.0"
      },
      {
        "date": "23-12-2022",
        "price": 0
      },
      {
        "date": "24-12-2022",
        "price": 0
      },
      {
        "date": "25-12-2022",
        "price": 0
      },
      {
        "date": "26-12-2022",
        "price": "24000.0"
      },
      {
        "date": "27-12-2022",
        "price": 0
      }
    ],
    "total_order_in_7_days": 16,
    "y_axis": {
      "y1": "price"
    },
    "x_axis": {
      "x1": "date"
    },
    "max_value": "24000.0"
  },
  "top_10_skus": {
    "data": [],
    "format": "table"
  },
  "avg_basket": {
    "data": [
      {
        "date": "21-12-2022",
        "price": "2319.0"
      },
      {
        "date": "22-12-2022",
        "price": "336.6"
      },
      {
        "date": "23-12-2022",
        "price": 0
      },
      {
        "date": "24-12-2022",
        "price": 0
      },
      {
        "date": "25-12-2022",
        "price": 0
      },
      {
        "date": "26-12-2022",
        "price": "24000.0"
      },
      {
        "date": "27-12-2022",
        "price": 0
      }
    ],
    "total_order_in_7_days": 16,
    "y_axis": {
      "y1": "price"
    },
    "x_axis": {
      "x1": "date"
    },
    "max_value": "24000.0"
  }
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
   "message": "#{ex.message}"
}
```
