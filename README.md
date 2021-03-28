# Jbuilder
[![Build Status](https://travis-ci.org/shootingfly/jbuilder.svg?branch=master)](https://travis-ci.org/shootingfly/jbuilder)[![GitHub release](https://img.shields.io/github/release/shootingfly/jbuilder.svg)](https://github.com/shootingfly/jbuilder/releases)

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
