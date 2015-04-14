# Peeps: A demo of JSONAPI-Resources

Peeps is a very basic contact management system implemented as an API that follows the JSON API spec.

## No really, What is this?

This project demonstrates how to use JSON API Resources with a NoSQL, ActiveModel replacement **without** ActiveRecord.

In this case, the demo uses Mongoid and MongoDB. In theory, NoBrainer and RethinkDB would also work with a few adjustments.

## Areas of Opportunity

This demo patches JSON API ResourceController to avoid using `ActiveRecord`. (see https://github.com/cerebris/jsonapi-resources/issues/51)

```ruby
module JSONAPI
  class ResourceController

    def create_operations_processor
      JSONAPI::OperationsProcessor.new
    end

  end
end
```

Record filtering relies on ActiveRecord to turn `records.where` into an `IN` query in SQL. This needs an adjustment (not currently included) to enable filtering in Mongoid. (see https://github.com/cerebris/jsonapi-resources/issues/118)

Some error handling tries to catch/rescue `ActiveRecord` errors like `ActiveRecord::RecordNotFound`. Sadly, `rescue ActiveRecord::RecordNotFound => e` throws an error because `ActiveRecord` isn't loaded. (see https://github.com/cerebris/jsonapi-resources/issues/127)

## Test it out

Start a mongo instance with `mongod`.

Launch the app

```bash
rails server
```

Create a new contact
```bash
curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{"data": {"type":"contacts", "name-first":"John", "name-last":"Doe", "email":"john.doe@boring.test"}}' http://localhost:3000/contacts
```

You should get something like this back
```
HTTP/1.1 201 Created
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
Etag: W/"aba27b88b6c51f0910ec995ab613e679"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 998edda8-e29a-4dfa-ad68-2b524d660aa7
X-Runtime: 0.147099
Server: WEBrick/1.3.1 (Ruby/2.2.0/2014-12-25)
Date: Thu, 19 Mar 2015 22:28:15 GMT
Content-Length: 312
Connection: Keep-Alive

{"data":{"id":"1","name-first":"John","name-last":"Doe","email":"john.doe@boring.test","twitter":null,"type":"contacts","links":{"self":"http://localhost:3000/contacts/1","phone-numbers":{"self":"http://localhost:3000/contacts/1/links/phone-numbers","related":"http://localhost:3000/contacts/1/phone-numbers"}}}}

```

You can now create a phone number for this contact

```
curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{"data": {"type":"phone-numbers", "links": {"contact": {"type": "contacts", "id":"1"}}, "name":"home", "phone-number":"(603) 555-1212"}}' "http://localhost:3000/phone-numbers"
```

And you should get back something like this:

```
HTTP/1.1 201 Created
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
Etag: W/"2addda2f434de1f85a7997e1d6185a2b"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 18febd47-a3e5-471e-8f8b-adf0db6c68fb
X-Runtime: 0.018462
Server: WEBrick/1.3.1 (Ruby/2.2.0/2014-12-25)
Date: Thu, 19 Mar 2015 22:28:38 GMT
Content-Length: 315
Connection: Keep-Alive

{"data":{"id":"1","name":"home","phone-number":"(603) 555-1212","type":"phone_numbers","links":{"self":"http://localhost:3000/phone-numbers/1","contact":{"self":"http://localhost:3000/phone-numbers/1/links/contact","related":"http://localhost:3000/phone-numbers/1/contact","linkage":{"type":"contacts","id":"1"}}}}}
```

You can now query all one of your contacts

```bash
curl -i -H "Accept: application/vnd.api+json" "http://localhost:3000/contacts"
```

And you get this back:

```
HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
Etag: W/"577b17ec60006c68fb522a2af809132a"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 524e0eb7-fb0d-4d26-9ba2-627bb625ab25
X-Runtime: 0.003388
Server: WEBrick/1.3.1 (Ruby/2.2.0/2014-12-25)
Date: Thu, 19 Mar 2015 22:29:05 GMT
Content-Length: 314
Connection: Keep-Alive

{"data":[{"id":"1","name-first":"John","name-last":"Doe","email":"john.doe@boring.test","twitter":null,"type":"contacts","links":{"self":"http://localhost:3000/contacts/1","phone-numbers":{"self":"http://localhost:3000/contacts/1/links/phone-numbers","related":"http://localhost:3000/contacts/1/phone-numbers"}}}]}
```

Note that the phone_number id is included in the links, but not the details of the phone number. You can get these by
setting an include:

```bash
curl -i -H "Accept: application/vnd.api+json" "http://localhost:3000/contacts?include=phone-numbers"
```

and some fields:
```bash
curl -i -H "Accept: application/vnd.api+json" "http://localhost:3000/contacts?include=phone-numbers&fields%5Bcontacts%5D=name-first,name-last&fields%5Bphone-numbers%5D=name"
```

Test a validation Error
```bash
curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{"data": {"type":"contacts", "name-first":"John Doe", "email":"john.doe@boring.test"}}' http://localhost:3000/contacts
```
