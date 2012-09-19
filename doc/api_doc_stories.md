* As an API client I can **POST** a `facebook_access_token` to `/users/build` and receive an unsaved user in json form.
* As an API client I can **POST** an `email` and `password` to `/authenticate` to receive their access token.
* As an API client I can **POST** a `facebook_access_token` to `/authenticate` to receive their access token.
* As an API client I can **POST** user parameters to `/users` to create a new user.
* As an authenticated API client I can **GET** `/users` to get a list of users in json form.
* As an authenticated API client I can **GET** `/users/:id` to get the specified user in json form.
* As an authenticated API client I can **GET** `/me` to get my own authenticated user in json form.
* As an authenticated API client I can **PUT** `/me` to update my own user data. I should get in response the updated object.
* As an authenticated API client I can **POST** a photo (multipart/form-data) to `/me/photo` to make that my primary photo.
* As an authenticated API client I can **GET** my current photo from `/me/photo` in json form.
* As an API client I can **GET** `/interests` to get a list of interests in json form.
* As an API client I can **GET** `/interests/:id` to get the specified interest in json form.
* As an API client I can **GET** `/locations` to get a list of locations in json form.
* As an API client I can **GET** `/locations/search/?latitude=X&longitude=Y` to get a list of locations near the specified latitude/longitude point in json form.
* As an API client I can **GET** `/locations/:id` to get the specified location in json form.
