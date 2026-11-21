# Jbuilder
[![Crystal CI](https://github.com/shootingfly/jbuilder/actions/workflows/crystal.yml/badge.svg)](https://github.com/shootingfly/jbuilder/actions/workflows/crystal.yml)
[![GitHub release](https://img.shields.io/github/release/shootingfly/jbuilder.svg)](https://github.com/shootingfly/jbuilder/releases)

Generate JSON objects with a Builder-style DSL, inspired by jbuilder (<https://github.com/rails/jbuilder>)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     jbuilder:
       github: shootingfly/jbuilder
   ```

2. Run `shards install`

## Usage

```crystal
require "jbuilder"
```

First, write down the code.
```crystal
Jbuilder.new do |json|
  json.null nil
  json.code 200
  json.msg "ok"
  json.merge!({"code" => 201})
  json.array! "array1", [1, 1.0, "1"]
  json.array!("array2", [1, 2, 3, 4]) do |json, item|
    json.code item
  end
  json.data do |json|
    json.code 400
    json.array! "array3", [1, 1.0, "1"]
  end
  json.set!("custom_field", %w[1 2])
end.to_json
```

Then you can see, 
```json
{
  "null":null,
  "code":201,
  "msg":"ok",
  "array1":[
    1,
    1.0,
    "1"
  ],
  "array2":[
    {
      "code":1
    },
    {
      "code":2
    },
    {
      "code":3
    },
    {
      "code":4
    }
  ],
  "data":{
    "code":400,
    "array3":[
      1,
      1.0,
      "1"
    ]
  },
  "custom_field":[
    "1",
    "2"
  ]
}
```

## Parsed and nested values

Fields accept `JSON::Any` directly, including parsed objects and arrays. Arrays,
hashes, tuples and named tuples can mix native values with parsed values at any
depth. `array!`, `hash!` and `merge!` use the same recursive conversion; null,
false and numeric types are preserved. Containers are copied when assigned, so
later source changes do not alter the rendered value.

```crystal
document = JSON.parse(%({"items":[null,false,{"name":"example"}]}))
Jbuilder.new do |json|
  json.document document
  json.array!("items", document["items"].as_a)
end
```

## Partial templates with explicit locals

Register the template directory once at the top level:

```crystal
Jbuilder.templates "src/views"
```

A reusable template declares its required local variables on the first line. For example, `src/views/users/profile.jbuilder`:

```crystal
# locals: user, active
json.id user.id
json.name user.name
json.active active
```

Call it from an embedded `.jbuilder` template using named locals:

```crystal
json.user do |json|
  json.partial! "users/profile", user: user, active: false
end
```

`partial!` is a template directive compiled by `Jbuilder.embed`, rather than a runtime file loader. Paths are literal strings relative to the registered directory; the `.jbuilder` suffix is optional. Each partial runs in a separate method on the current builder, with only its declared locals. The caller's local variables remain unchanged. Nested partials must also pass their locals explicitly.

Unknown paths, missing or extra locals, and dynamic paths are reported during compilation. Named expressions are evaluated once; `false` and `nil` are passed unchanged. Templates are compiled into the application, so neither template files nor the build-time compiler are required at runtime. Existing layouts and embedded templates remain supported.

## An example using Kemal
https://github.com/shootingfly/kemal-jbuilder-example

## Changelog
+ **v1.0.0**
  + Support Crystal 1.0.0
+ **v0.3.0**
  + Support Tuple and Named Tuple
  + Support render with layout and child template
+ **v0.2.0**
  + Support Kilt
+ **v0.1.0**
  + First Release

## Contributing

1. Fork it (<https://github.com/shootingfly/jbuilder/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Shooting Fly](https://github.com/shootingfly) - creator and maintainer
