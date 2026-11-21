name = "outer"
json.item do |json|
  json.partial! "scoped", name: "inner"
end
json.name name
