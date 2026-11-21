# locals: names
json.array!("items", names) do |json, name|
  json.partial! "item", name: name, active: false
end
