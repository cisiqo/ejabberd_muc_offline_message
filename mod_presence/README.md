Purpose:
=========

Forward several types of messages as post requests to an arbitrary url.

mod\_offline\_post forwards messages that are sent to offline users through a post request to a configurable url
mod\_available\_post sends a post request with information about a user that has become available
mod\_unavailable\_post sends a post request with information about a user that has gone offline

Note:
==========

Between ejabberd 2.1.13 and 13.10 there were significant changes and modules compiled for one version don't directly work with the other version.
There is an ejabberd_2.1.13 branch for versions of these modules that work with ejabberd 2.1.13

Installing:
==========

* Make sure you have erlang installed on the machine you are building from
  * You probably want this to be the same machine you intend to install/run ejabberd on. I'm not sure about the interoperability of ejabberd/erlang versions.
* Open the Emakefile and change ```/usr/local/Cellar/ejabberd/2.1.10/lib/ejabberd/include``` to the correct path on your machine
* Run the build.sh script to build *.beam files
* Copy the *.beam files from the ebin directory to the location where the other modules are for your server
* Add the configuration shown below to your ejabberd.cfg file, providing the correct values for auth\_token, and post\_url

Example Configuration:
=====================

		% configuration for ejabberd upto version 13.10
		{mod_offline_post, [
			{auth_token, "offline_post_auth_token"},
			{post_url, "http://localhost:4567/offline_post"}
		]}
		{mod_available_post, [
			{auth_token, "mod_available_post"},
			{post_url, "http://localhost:4567/available_post"}
		]}
		{mod_unavailable_post, [
			{auth_token, "unavailable_post_auth_token"},
			{post_url, "http://localhost:4567/unavailable_post"}
		]}

    # configuration for ejabberd >= 13.10
		mod_offline_post:
			auth_token: "offline_post_auth_token"
			post_url: "http://localhost:4567/offline_post"

		mod_available_post:
			auth_token: "available_post_auth_token"
			post_url: "http://localhost:4567/available_post"

		mod_unavailable_post:
			auth_token: "unavailable_post_auth_token"
			post_url: "http://localhost:4567/unavailable_post"

Results:
========

The application running at the post_url will receive a post http request with the following form parameters.

		mod_offline_post
		"to"=>"adam2@localhost"
		"from"=>"adam1"
		"body"=>"Does it still work?"
		"access_token"=>"offline_post_auth_token"

		mod_available_post
		"jabber_id"=>"adam2"
		"access_token"=>"mod_available_post"

		mod_unavailable_post
		"jabber_id"=>"adam2"
		"access_token"=>"unavailable_post_auth_token"

License
========
The modules herein are almost entirely based on mod\_offline\_prowl written by Robert George <rgeorge@midnightweb.net>
They retain the original author's license.

The original post about mod\_offline\_prowl can be found [here](http://www.unsleeping.com/2010/07/31/prowl-module-for-ejabberd/)
