# EmailFetchAndProcess

This little gem encapsulates some logic distilled and extracted from a bunch of different scripts used to access a mailbox, find an email, and get the file attachment from it.

It is currently very focused and limited to that job and that job only, but with a little TLC it could become a more general email access/extract/process tool.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'email-fetch-and-process'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install email-fetch-and-process

## Usage

```
require 'email-fetch-and-process'

job = EmailFetchAndProcess::Job.new({fetch: ['SUBJECT', 'Some subject line']})
r = EmailFetchAndProcess.new({host: 'imap.gmail.com',port: 993, id: 'YOURID', password: 'YOURPASSWORD'})

r.run([job])
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wyhaines/email-fetch-and-process.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
