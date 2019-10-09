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
