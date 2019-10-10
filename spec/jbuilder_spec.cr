require "./spec_helper"

describe Jbuilder do
  it "works with full example" do
    jbuilder = Jbuilder.new do |json|
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
    end
    jbuilder.should be_a(Hash(String, Jbuilder::BasicObject))
  end

  it "works with NULL" do
    jbuilder = Jbuilder.new do |json|
      json.null nil
    end
    jbuilder.to_json.should eq({
      null: nil,
    }.to_json)
  end

  it "works with Bool" do
    jbuilder = Jbuilder.new do |json|
      json.true true
      json.false false
    end
    jbuilder.to_json.should eq({
      "true"  => true,
      "false" => false,
    }.to_json)
  end

  it "works with Float" do
    jbuilder = Jbuilder.new do |json|
      json.min_float32 Float32::MIN
      json.max_float32 Float32::MAX
      json.min_float64 Float64::MIN
      json.max_float64 Float64::MAX
    end
    jbuilder.to_json.should eq({
      "min_float32" => Float32::MIN,
      "max_float32" => Float32::MAX,
      "min_float64" => Float64::MIN,
      "max_float64" => Float64::MAX,
    }.to_json)
  end

  it "works with Integer" do
    jbuilder = Jbuilder.new do |json|
      json.min_uint8 UInt8::MIN
      json.max_uint8 UInt8::MAX
      json.min_uint16 UInt16::MIN
      json.min_uint16 UInt16::MAX
      json.min_uint32 UInt32::MIN
      json.max_uint32 UInt32::MAX
      json.min_uint64 UInt64::MIN
      json.max_uint64 UInt64::MAX
      json.min_uint128 UInt128::MIN
      json.max_uint128 UInt128::MAX
      json.min_int8 Int8::MIN
      json.max_int8 Int8::MAX
      json.min_int16 Int16::MIN
      json.min_int16 Int16::MAX
      json.min_int32 Int32::MIN
      json.max_int32 Int32::MAX
      json.min_int64 Int64::MIN
      json.max_int64 Int64::MAX
      json.min_int128 Int128::MIN
      json.max_int128 Int128::MAX
    end
    jbuilder.to_json.should eq({
      "min_uint8"   => UInt8::MIN,
      "max_uint8"   => UInt8::MAX,
      "min_uint16"  => UInt16::MIN,
      "min_uint16"  => UInt16::MAX,
      "min_uint32"  => UInt32::MIN,
      "max_uint32"  => UInt32::MAX,
      "min_uint64"  => UInt64::MIN,
      "max_uint64"  => UInt64::MAX,
      "min_uint128" => UInt128::MIN,
      "max_uint128" => UInt128::MAX,
      "min_int8"    => Int8::MIN,
      "max_int8"    => Int8::MAX,
      "min_int16"   => Int16::MIN,
      "min_int16"   => Int16::MAX,
      "min_int32"   => Int32::MIN,
      "max_int32"   => Int32::MAX,
      "min_int64"   => Int64::MIN,
      "max_int64"   => Int64::MAX,
      "min_int128"  => Int128::MIN,
      "max_int128"  => Int128::MAX,
    }.to_json)
  end

  it "works with String" do
    jbuilder = Jbuilder.new do |json|
      json.string "Hello World"
    end
    jbuilder.to_json.should eq({
      "string" => "Hello World",
    }.to_json)
  end

  it "works with Array" do
    weeks = [
      [1, "Monday"],
      [2, "Tuesdaty"],
      [3, "Wednesday"],
      [4, "Thursday"],
      [5, "Friday"],
      [6, "Saturday"],
      [7, "Sunday"],
    ]
    jbuilder = Jbuilder.new do |json|
      json.array! "array1", [1, 2, 3]
      json.array! "array2", [1, 2.0, "3", nil]
      json.array! "array3", weeks do |json, item|
        json.index item[0]
        json.day item[1]
      end
    end
    jbuilder.to_json.should eq({
      "array1" => [1, 2, 3],
      "array2" => [1, 2.0, "3", nil],
      "array3" => weeks.map do |item|
        {
          "index" => item[0],
          "day"   => item[1],
        }
      end,
    }.to_json)
  end

  it "works with Hash" do
    current_time = Time.local
    user = UserCase.new(
      id: Int64::MAX,
      nick_name: "Jbuilder",
      email: "example@jbuilder.org",
      age: 25,
      is_male: true,
      created_at: current_time,
      hobbits: %w[Crystal Ruby Python PHP JAVA]
    )
    jbuilder = Jbuilder.new do |json|
      json.object do |json|
        json.id user.id
        json.nick_name user.nick_name
        json.email user.email
        json.age user.age
        json.is_male user.is_male
        json.created_at user.created_at
        json.array! "hobbits", user.hobbits
      end
    end
    jbuilder.to_json.should eq({
      object: {
        id:         Int64::MAX,
        nick_name:  "Jbuilder",
        email:      "example@jbuilder.org",
        age:        25,
        is_male:    true,
        created_at: current_time,
        hobbits:    user.hobbits,
      },
    }.to_json)
  end
end
