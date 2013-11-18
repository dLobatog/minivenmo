# Minivenmo

# Installation

Install Ruby stable (1.9.3)
`gem install bundler`

Run `bundle install` to clear dependencies.

Configure your database adaptor in db/database.yaml.
> Minivenmo ships with a default interface for sqlite but it supports any database backend that ActiveRecord supports. It has only been tested with sqlite so if you find any problem with other databases please raise a ticket or submit a pull request with a fix.

Run `rake db:migrate` from Minivenmo's main directory to create the database schema
from db/migrate.

'lib/secret' contains a secret that is used to encrypt credit card numbers.
Use the default secret for testing or find a way to set up your own.
> The secret should be at least as long as the cipher key size. Credit cards are encrypted with an 'aes-256-cbc' cipher, so this is 256 bits. You can generate a suitable key with OpenSSL::Digest::SHA256.new('yoursecret').digest

# Testing

`rake test` should recreate the testing database and run all tests in spec/.

# Usage:

Run bin/minivenmo --help to see all possible options.

`bin/minivenmo` works with regular commands as a command-line program.

`bin/minivenmo shell` brings up a minishell that works with Minivenmo commands.

`bin/minivenmo --file inputfile` runs all commands in inputfile in order.
You can find a file example 'testinput' at spec/fixtures/testinput.
