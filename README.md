A simple gem for fetching Fortnox integration access token using authorization code

[Fortnox AIP documentation](https://developer.fortnox.se/documentation/general/authentication/)

For the gem to work it requires three parts:

* Fortnox base uri: Forntox base uri can be set as an environment variable with the key 'FORTNOX_BASE_URL' or will use the default 'https://api.fortnox.se/3/'.
* Authorization code: The code a Fortnox user will receive when adding an integration. See [Fortnox AIP documentation](https://developer.fortnox.se/documentation/general/authentication/). Authorization code is sent in as the first argument to the 'retrieve!' method.
* Client secret: Uniqe identifier for your integration you will receive in the registration email when you register as a developer at Fortnox. Client secret can be set as an environment variable with the key 'CLIENT_SECRET' or sent in as the second argument to the 'retrieve! method'.

IMPORTANT: Each authorization code can only be used to request an access token once, if Fortnox has received the code before it will deactivate any integration using the access token.
```
FortnoxAccessToken.new(authorization_code, client_secret:).retrieve!
````
