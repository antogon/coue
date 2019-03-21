# Coue
An "extension" for [`geocoder`](https://github.com/alexreisner/geocoder) that adds
much needed support for autosuggest APIs as exposed by many of the popular
geocoding sources already supported by `geocoder`.

## About
This collection of convenient monkey patches originates from a series of
discussions that ultimately resulted in a simple conclusion -- `geocoder` does
not intend to provide native support for the autosuggest APIs aforementioned.

For those of us who already rely on `geocoder`, this is a stumbling point
because it causes us to implement a client against these APIs anyway.  To keep
things clean-ish, I put the necessary changes into this gem.

Special thanks to @MrFenril who raised
[this creative PR](https://github.com/alexreisner/geocoder/pull/1383) on which
most of these changes are based.

## Contributing
We don't support all the autosuggest APIs that are exposed by the engines
`geocoder` supports, but we would like to!  Please feel free to contribute
your own additions so long as you also give us a test case or two!

To run the test suite:
```
bundle exec rake test
```

Keep in mind, we use `webmock` to keep this test suite standalone.  Be sure to
leverage it when you write specs testing integration against new HTTP APIs.
