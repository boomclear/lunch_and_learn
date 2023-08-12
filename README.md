This project is a backend API that allows you to find recipes for specific countries and learning resources. It also allows you to create and authenticate users, and save favorites recipes to those users.

### JSON API Contract

**GET api/v1/recipes**

OR

**GET api/v1/recipes?country=laos**

For this endpoint you can either specify a country or not. If a country is not specified than a random country will be selected. It returns recipes from the country.

```
{
    "data": [
        {

            "id": "null",
            "type": "recipe",
            "attributes": {
                "title": "Tiger Salad (Lao Hu Cai) Recipe, à la Xi'an Famous Foods",
                "url": "https://www.seriouseats.com/recipes/2019/06/tiger-salad-recipe.html",
                "country": "laos",
                "image": "https://edamam-product-images.s3.amazonaws.com/..."

        },
        {
            "id": "null",
            "type": "recipe",
            "attributes": {
                "title": "Nam Khao",
                "url": "https://food52.com/recipes/67233-nam-khao",
                "country": "laos",
                "image": "https://edamam-product-images.s3.amazonaws.com/..."
            }
        }, ...
        }
    ]
}
```

**GET /api/v1/learning_resources?country=laos**

For this endpoint you have to specify a country, it returns a video and images for the country.

```
{
    "data": {
        "id": "null",
        "type": "learning_resource",
        "attributes": {
            "country": "laos",
            "video": {
                "title": "A Super Quick History of Laos",
                "youtube_video_id": "uw8hjVqxMXw"
            },
            "images": [
                {
                    "alt_tag": "The picture taken in Laos, 06:00, from hot baloon",
                    "url": "https://images.unsplash.com/photo-1540611025311-01df3cef54b5?ixid=M3w0ODUxNjh8MHwxfHNlYXJjaHwxfHxsYW9zfGVufDB8fHx8MTY5MTg2MjczOHww&ixlib=rb-4.0.3"
                },
                ...
            ]
        }
    }
}
```

**POST /api/v1/users**

This endpoint creates new users that store favorites. When making a post request to this endpoint send a JSON payload as specified below. An api key will also be created for you.

request:

```
{
  "name": "Odell",
  "email": "goodboy@ruffruff.com",
  "password": "treats4lyf",
  "password_confirmation": "treats4lyf"
}
```

response:

```
{
    "data": {
        "id": "1",
        "type": "user",
        "attributes": {
            "name": "Odell",
            "email": "goodboy@ruffruff.com",
            "api_key": "ac757e90b18b8d9bbaf75fb35b5fbee5"
        }
    }
}
```

**POST /api/v1/sessions**

This endpoint will authenticate you as a user and return your API key.

request:

```
{
  "email": "goodboy@ruffruff.com",
  "password": "treats4lyf"
}
```

response:

```
{
    "data": {
        "id": "1",
        "type": "user",
        "attributes": {
            "name": "Odell",
            "email": "goodboy@ruffruff.com",
            "api_key": "ac757e90b18b8d9bbaf75fb35b5fbee5"
        }
    }
}
```

**POST /api/v1/favorites**

This endpoint will save a favorite recipe to your user. This enpoint requires an API key.

request:

```
{
    "api_key": "ac757e90b18b8d9bbaf75fb35b5fbee5",
    "recipe_link": "www.google.com",
    "recipe_title": "food",
    "country": "laos"
}
```

response:

```
{
    "success": "Favorite added successfully"
}
```

**GET /api/v1/favorites?api_key=ac757e90b18b8d9bbaf75fb35b5fbee5**

This endpoint will fetch all favorites saved under your user(api key).

```
{
    "data": [
        {
            "id": "1",
            "type": "favorite",
            "attributes": {
                "recipe_title": "food",
                "recipe_link": "www.google.com",
                "country": "laos",
                "created_at": "2023-08-12T18:16:34.547Z"
            }
        },
        {
            "id": "2",
            "type": "favorite",
            "attributes": {
                "recipe_title": "food",
                "recipe_link": "www.google.com",
                "country": "laos",
                "created_at": "2023-08-12T18:16:51.762Z"
            }
        }
    ]
}
```
