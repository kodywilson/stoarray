stoarray
========

Library for making api calls to storage arrays with Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stoarray'
```

And then execute:

    $ gem install stoarray

## Usage

In your script:

```ruby
require 'stoarray'
```

EMC's Xtremio and Pure's storage arrays are currently supported.

Both api's use json for parameters and the examples below follow suit.
I prefer to set variables that will not change in a json configuration file.
It is very easy to then build from there.

## Clone refresh using Pure
---------------------------

###First the json configuration file:

    {
      "authorization": "123li123o90yourapitoken2h1hi3",
      "base_url": "https://purearray01.something.net/api/1.4/",
      "headers": { "Content-Type": "application/json" },
      "params_snap_u23": {
        "snap_pairs": {
          "x0319t186_u23_1_src": "x0319t186_u23_1_des",
          "x0319t186_u23_2_src": "x0319t186_u23_2_des",
          "x0319t186_u23_3_src": "x0319t186_u23_3_des",
          "x0319t186_u23_4_src": "x0319t186_u23_4_des",
          "x0319t186_u23_5_src": "x0319t186_u23_5_des"
        },
        "source": [
          "x0319t186u23"
        ]
      }
    }

The top three likely will not change between api calls.

+ authorization - This is your api token.
+ base_url      - URL for your array and api version
+ headers       - Pass the content type (JSON in this case)

These are what you need to set for clone refreshes. In this example,
they are nested under "params_snap_u23".

+ snap_pairs    - Map source volume(s) to target volume(s).
+ source        - This is the name of the source protection group.

###Back to your script, after the require 'stoarray'

```ruby
# Location of json configuration file and api token
conf    = JSON.parse(File.read('/Some/path/pure.json'))
token   = conf['authorization']
```

Pure uses cookies. You trade one for your api token and then you can use the cookie
while your session persists (30 minute inactivity timeout, unless you destroy it early).

```ruby
# Get a cookie for our session - required by Pure.
url     = conf['base_url'] + 'auth/session'
headers = conf['headers']
params  = { api_token: token }
cookies = Stoarray.new(headers: headers, meth: 'Post', params: params, url: url).cookie

# After we get a cookie, update headers to include it
headers['Cookie'] = cookies
```

Now we will send application type json and the cookie with each call.

```ruby
# Now refresh the clones
params = conf['params_snap_u23']
refresh = Stoarray.new(headers: headers, meth: 'Post', params: params, url: conf['base_url']).refresh
puts "Status:   " + refresh['status'].to_s
puts "Response: " + refresh['response'].to_s
```

In the above example, the source protection group is first snapped.
Next, each target volume is overwritten with the source snapshot (snap_pairs).
Any error along the way will cause the gem to return all status codes
and all array responses. Success gives a 201, SUCCESS.

## Xtremio clone refresh, json first
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

+ base_url        - URL for your array and api
+ headers         - Content type and authorization
+ authorization - "Basic 'Base64 hash of your username and password'"

###Now for your script - this one does a clone refresh

```ruby
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
```

## Troubleshooting

error 307 - Enter fully qualified domain name (FQDN) for the array to fix.
    purearray01.something.net instead of just purearray01

Solaris 10 - You may have to specify the path to make/gmake to install the gem.

A note about the flippy method in array_calls.rb:

    # This method is to get around a "feature" of Xtremio where it renames the
    # target snapshot set during a refresh making it more difficult to automate
    # refreshes as the target keeps changing names. Instead of doing that we
    # flip back and forth between to-snapshot-set-id and to-snapshot-set-id_347.
    # Pass the consistent name, "to-snapshot-set-id" and it flips for you.

Essentially, by design, the array wants to rename the target snapshot set when you refresh. This is not cool when you want to use a consistent name for the set, ie. for automation. The flippy method takes the to-snapshot-set-id from your json or passed as a parameter and then flips back and forth between it and to-snapshot-set-id_347. This way you can keep the same name in your json/scripts, etc.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install` or follow the instructions at the top of the readme.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kodywilson/stoarray. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[![Build Status](https://travis-ci.org/kodywilson/stoarray.svg?branch=master)](https://travis-ci.org/kodywilson/stoarray)

[![Gem Version](https://badge.fury.io/rb/stoarray.svg)](https://badge.fury.io/rb/stoarray)

[![Coverage Status](https://coveralls.io/repos/kodywilson/stoarray/badge.svg?branch=master&service=github)](https://coveralls.io/github/kodywilson/stoarray?branch=master)
