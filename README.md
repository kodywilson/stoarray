stoarray
========

Library for making api calls to storage arrays with Ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stoarray'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stoarray

## Usage

In your script:

    require 'stoarray'

EMC's Xtremio and Pure's storage arrays are currently supported.

Both api's use json for parameters and my examples below follow suit.
I prefer to set variables that will not change in a json configuration file.
It is very easy to then build from there.

Examples using Pure:
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
    puts host['response']

    # Create volumes and map them to new host
    conf['new_luns_testsrv01'].each do |vol|
      url_vol = conf['base_url'] + 'volume/' + vol
      voly = Stoarray.new(headers: headers, meth: 'Post', params: { :size => "10G" }, url: url_vol).volume
      puts JSON.parse(voly.body) if verbose == true
      url_map = url_host + '/volume/' + vol
      mappy = Stoarray.new(headers: headers, meth: 'Post', params: {}, url: url_map).host
      puts mappy['response'] if verbose == true
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
    puts "Status:   " + refresh['status'].to_s
    puts "Response: " + refresh['response'].to_s

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install` or follow the instructions at the top of the readme.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kodywilson/stoarray. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
