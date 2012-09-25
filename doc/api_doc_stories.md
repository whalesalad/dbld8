## API Access

* `https://api.dbld8.com` will be the final endpoint.
* `http://api.dbld8.com` works for our development needs, so you can inspect the http traffic.

---

## Section

#### Subsection
Body, body, body this will be markdown


## Creating a User

#### Creating a user with Facebook
* As an API client I can **POST** a `facebook_access_token` to `/users/build` and receive an unsaved user.

#### Creating a user with Emxqail / Password
* As an API client I can **POST** user parameters to `/users` to create a new user.

## Authenticating a User

#### Logging a user in with Email / Password
* As an API client I can **POST** an `email` and `password` to `/authenticate` to receive their access token.

#### Logging a user in via Facebook
* As an API client I can **POST** a `facebook_access_token` to `/authenticate` to receive their access token.

## Manipulating the Authenticated User

#### Getting the Auth'd User
* As an authenticated API client I can **GET** `/me` to get my own authenticated user.

#### Updating the Auth'd User
* As an authenticated API client I can **PUT** `/me` to update my own user data. Newly modified user object is returned on success.

#### Changing a Users Photo
* As an authenticated API client I can **POST** a photo (multipart/form-data) to `/me/photo` to make that my primary photo.

#### Getting the Users Photo
* As an authenticated API client I can **GET** my current photo from `/me/photo` in json form.

## Other Users

#### Get all users
* As an authenticated API client I can **GET** `/users` to get a list of users in json form.

#### Get info on a specific user
* As an authenticated API client I can **GET** `/users/:id` to get the specified user in json form.

### Getting Interests

* As an API client I can **GET** `/interests` to get a list of interests in json form.
* As an API client I can **GET** `/interests?query=<query>` to find interests matching the `query` parameter 
* As an API client I can **GET** `/interests/:id` to get the specified interest in json form.

### Locations

* As an API client I can **GET** `/locations` to get a list of locations in json form.
* As an API client I can **GET** `/locations?latitude=<latitude>&longitude=<longitude>` to get a list of locations near the specified `latitude`/`longitude` point in json form.
* As an API client I can **GET** `/locations/:id` to get the specified location in json form.