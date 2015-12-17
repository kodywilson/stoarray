stoarray
========

Library for making api calls to storage arrays with Ruby

    gem install stoarray

In your script:

    require 'stoarray'

EMC's Xtremio and Pure's storage arrays are currently supported. PURE IS
NOT WORKING RIGHT NOW!!!

Both api's use json for parameters and my examples below follow suit.
I prefer to set variables that will not change in a json configuration file.
It is very easy to then build from there.

Examples using Pure: DON'T USE THESE EXAMPLES. THE GEM HAS BEEN UPDATED
AND TESTED WITH XTREMIO BUT NOT PURE!
--------------------

###First the json configuration file:
    {
      "authorization":"123li123o90yourapitoken2h1hi3",
      "base_url":"https://purearray01/api/1.4/",
      "headers": { "Content-Type": "application/json" },
      "newhost": "testsrv01",
      "new_luns_testsrv01": [
        "testsrv01_u23_1_src",
        "testsrv01_u23_2_src",
        "testsrv01_u23_3_src",
        "testsrv01_u23_4_src",
        "testsrv01_u23_5_src"
        ],
      "params_host_testsrv01": {
        "wwnlist":  [
          "10:00:00:00:C1:A3:BG:16",
          "10:00:00:00:C1:A3:BG:17"
          ]
      }
    }

The top three likely will not change between api calls.
authorization - This is your api token.
base_url      - URL for your array and api
headers       - Pass the content type (JSON in this case)

###Back to your script, after the require 'stoarray'

    # Location of json configuration file and api token
    conf    = JSON.parse(File.read('/Users/yourid/pure.json'))
    token   = conf['authorization']

Pure uses cookies. You get one with your api token and then it uses the cookie
while your session persists (30 mins max unless you destroy it early).

    # Get a cookie for our session
    url     = conf['base_url'] + 'auth/session'
    headers = conf['headers']
    params  = { api_token: token }
    cookies = Stoarray.new(headers: headers, meth: 'Post', params: params, url: url).cookie

    # After we get a cookie, update headers to include it
    headers['Cookie'] = cookies

Now we will send application type json and the cookie with each call.

    # Create host and set list of WWN's
    params   = conf['params_host_testsrv01']
    url_host = conf['base_url'] + 'host/' + conf['newhost']
    host     = Stoarray.new(headers: headers, meth: 'Post', params: params, url: url_host).host
    puts JSON.parse(host.body)

    # Create volumes and map them to new host
    conf['new_luns_testsrv01'].each do |vol|
      url_vol = conf['base_url'] + 'volume/' + vol
      voly = Stoarray.new(headers: headers, meth: 'Post', params: { :size => "10G" }, url: url_vol).volume
      puts JSON.parse(voly.body) if verbose == true
      url_map = url_host + '/volume/' + vol
      mappy = Stoarray.new(headers: headers, meth: 'Post', params: {}, url: url_map).host
      puts JSON.parse(mappy.body) if verbose == true
    end

In this example, you end up with a new host on the array, named testsrv01, including WWN's, and 5 10GB volumes mapped to the host.

###Now for Xtremio, json first:
    {
      "base_url":"https://xmsserver01/api/json/v2/types/",
      "headers": {
        "Content-Type": "application/json",
        "authorization":"Basic alsdkjfsldakjflkdsjflkasdj=="
      },
      "params_refresh_u04": {
        "cluster-id": "xtrmcluster01",
        "from-consistency-group-id": "x0319t186_u04_src",
        "to-snapshot-set-id": "x0319t186_u04_des"
      }
    }

base_url        - URL for your array and api
headers         - Content type and authorization
  authorization - "Basic 'Base64 hash of your username and password'"

###Now for your script - this one does a clone refresh

    #!/usr/bin/env ruby

    require 'stoarray'

    # Location of json configuration file
    conf    = JSON.parse(File.read('/path/to/config/file/xtremioclone.json'))

    headers = conf['headers']

    # Refresh the snap set
    url = conf['base_url'] + 'snapshots'
    params  = conf['params_refresh_u04']
    refresh = Stoarray.new(headers: headers, meth: 'Post', params: params, url: url).refresh
    puts "Status:   " + refresh['status']
    puts "Response: " + refresh['response'].to_s
