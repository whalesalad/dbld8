# API Documentation

All URL's should be prefixed with `https://api.dbld8.com`

**Registration**  The user will be able to register one of two types of accounts. First, A regular account, which will authorize via email address and password. Second, and preferred, via Facebook.

### Create a new User (without facebook)

#### POST /users/

The `POST` should contain the following:

	{ "user": { 
		"first_name": "Michael", 
		"last_name": "Whalen", 
		"birthday": "YYYY-MM-DD", 
		"single": true, 
		"interested_in": "girls",
		"gender": "male",
		"bio":"I am going to rule the world!",
		"email":"michael@belluba.com",
		"password":"music7" 
	}}

Breakdown of attributes:

* `single` is `true` or `false`
* `interested_in` can be one of `guys`, `girls`, or `both`
* `gender` can be simply `male` or `female`
* `email` is not required
* `password` is not required

If this is successful, a full user object will be returned along with a `HTTP/1.1 200 OK`

	{
	    "birthday": "1989-10-02",
	    "bio": "I am going to rule the world!",
	    "last_name": "Whalen",
	    "id": 2,
	    "facebook_id": null,
	    "gender": "male",
	    "email": "michael@belluba.com",
	    "age": 22,
	    "photo": null,
	    "first_name": "Michael",
	    "interested_in": "girls",
	    "single": true
	}

### Create a new User with Facebook

#### POST /users/

To create a new user with Facebook, post their Facebook user ID as `facebook_id` and their Facebook `access_token` provided by authenticating in the iOS app. Their user object will be returned, prepopulated by data from Facebook for your convenience. You can optionally post other details which will override anything returned from Facebook. Anything you do not specify that we can collect from Facebook, will be stored in the user object.

	{
		user_id: 1
		photo: http://static.dbld8.com/users/1/profile/103844813.jpg
		email: 'michael@belluba.com'
		first_name: 'John',
		last_name: 'Smith',
		birthday: 'MM/DD/YYYY',
		age: 30,
		status: 'single',
		interest: 'women',
		gender: 'male',
		bio_text: 'I am going to rule the world!'
		location: {
			id: 34587,
			fb_id: 48575,
			name: 'Washington, DC',
			lat: -33.334
			lng: 7.384
		},
		interests: [ empty ]
	}

Notice that because we were able to externally fetch their Facebook info, a photo is automatically provided.

### User Interests

Interests are like tags. They are simple strings, meant to be unique. Like a Twitter hashtag. Interests should be shared amongst users. For example, if I enter 'Running' as an interest, it should connect to a database object that other users can choose down the road.

#### GET /interests/

This will fetch all interests from the database.

	[
	    {
	        "name": "Hiking",
	        "id": 1,
	        "facebook_id": 105525412814559
	    },
	    {
	        "name": "Camping",
	        "id": 2,
	        "facebook_id": 105426616157521
	    },
	    {
	        "name": "Running",
	        "id": 4,
	        "facebook_id": 109368782422374
	    },
	    {
	        "name": "Cats",
	        "id": 8,
	        "facebook_id": 111851445501172
	    },
	    {
	        "name": "Dogs",
	        "id": 9,
	        "facebook_id": 114197241930754
	    },
	    {
	        "name": "Coffee",
	        "id": 10,
	        "facebook_id": 103758506330178
	    }
	]


This is not very handy, however. We want to be able to query for interests based on the name, as quickly as the user types.

#### GET /interests/?q=<search_parameter>

You can pass a `q` query to `/interests/` to search for interests matching that name. Search is case-insensitive.

	[
	    {
	        "name": "Running",
	        "id": 4,
	        "facebook_id": 109368782422374
	    }
	]

#### GET /interests/:id/

Pass a single `id` to get the details of that interest.

	{
	    "name": "Surfing",
	    "id": 5,
	    "facebook_id": 111932052156866
	}

#### POST /interests/

You can POST to this endpoint to create a new interest.

Example POST:

	{ "interest": { "name": "Starbucks" } }

Example response:

	{
	    "name": "Starbucks",
	    "id": 12,
	    "facebook_id": null
	}

If you try and POST a resource with a name that already exists, a `422 - Unprocessable Entity` response is returned. The name validation is case-insensitive, so posting STARBUCKS will not work if an interest with the name 'Starbucks' exists.