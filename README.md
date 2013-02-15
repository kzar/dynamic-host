Dynamic Host
------------

Small script that leverages the [pointHQ](http://pointhq.com/) [Ruby library](https://github.com/atech/point) to provide no-ip / dyn-dns like functionality.

Usage
-----

Create a `config.yml` file based on `config.yml.example`.
Install the dependencies: `bundle install`.
Test the script works: `ruby dynamic-host.rb`
Set up a cronjob to run the above `* * * * * ruby /path/to/dynamic-host.rb`

License
-------

By Dave Barker 2013, released under MIT License.