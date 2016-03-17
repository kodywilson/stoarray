# CHANGELOG for stoarray

This file is used to list changes made to the stoarray gem.

## 03172016

* All code should have test coverage now!
* Conversion to rest-client complete. Removed getty, del33t, verbal_gerbil.
* make_call - (previously cally) Added rescue so I can return error messages.
* cookie - Removed "testy" stuff & added break on failure (raise).
* Consistent success messages for both Pure and Xtremio clone refreshes.

## 03152016

* Add Mark Gibbon's line to generate an error if a valid cookie is not received.
* All code should be covered now except the cookie block!

## 03142016

* Additional tests using mockable.io: Refresh and flippy covered now.
* New delete method using rest-client. Needs work! (handling params).

## 03112016

* Using mockable.io for API call testing, updating rspec tests.

## 03102016

* Added new array method for gathering stats from the arrays.

## 03092016

* Break call setup out of initialize and into new methods.
* Update dependent methods to use new call methods.
* Add rest-client gem to resolve issue with GETs on Xtremio.

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
