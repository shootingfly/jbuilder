calls = 0
json.partial!("item", name: (calls += 1).to_s, active: nil)
json.calls calls
