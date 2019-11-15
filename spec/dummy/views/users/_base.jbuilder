json.array! "users", ["Tom", "Lisa"] do |json, item|
  json.nick_name item
end
