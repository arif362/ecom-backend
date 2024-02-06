### SHOW A STATIC PAGE
___

* **URL :** `BASE_URL + /shop/api/v1/static_pages/:page_type`
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
  "message": "Successfully Fetch",
  "data": {
    "id": 6,
    "page_type": "Home Page",
    "meta_info": {
      "meta_title": "Shopoth.com | Trusted Online Shopping from Local Outlets at Fair Price",
      "bn_meta_title": "Shopoth.com | Trusted Online Shopping from Local Outlets at Fair Price",
      "meta_description": "Trusted online shopping experience in Bangladesh from your local outlets anytime at fair price.",
      "bn_meta_description": "Trusted online shopping experience in Bangladesh from your local outlets anytime at fair price",
      "meta_keyword": [
        "ggg",
        "sd",
        "sads",
        "sadsd",
        "sdsad",
        "sadsad",
        "skjdhskjd",
        "hdgdss",
        "hdgjhdg",
        "djhgjgf",
        "dhfjdhfgdf",
        "jhgjhgdj",
        "hgjhfgd",
        "sdksajdksahdls",
        "ahdjadsj",
        "ahsaks",
        "skjdksjdk",
        "jsjhlkjlkjdlsakjdlksajdlsakjdlsk",
        "ksdkjdhks",
        "dkjhdkjshdkj",
        "sjvjshkjdk",
        "skjshkjdkj",
        "jaldjlsjdlsj",
        "lsdjalskdlksj",
        "'",
        "kjldkjdlks",
        "dsjdhs",
        "sdshsjhd",
        "ddlsl",
        "djshdlks"
      ],
      "bn_meta_keyword": [
        "df,gnkldg ",
        "fdgklgj",
        "lkdlsk k;k'",
        "klk;lk;l",
        "jskjslsjd",
        "slsjdsl",
        "skdjslkjdlk",
        "skjdlk",
        "kdjl",
        "dkj",
        "lksjl",
        "lsll",
        "jsk",
        "ksjl",
        "sj",
        "j"
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
   "message": "#{error}",
   "data": {}
}
```
