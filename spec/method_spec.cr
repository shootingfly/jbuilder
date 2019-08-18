require "./spec_helper"

describe Jbuilder do
  it "#set!" do
    jbuilder = Jbuilder.new do |json|
      json.set!("number", 100)
      json.set!("string", "100")
      json.set!("array", [1, 1.0, "1", true])
      json.set!("hash", {
        "code" => 200,
        "msg"  => "success",
      })
    end
    jbuilder.to_json.should eq({
      "number" => 100,
      "string" => "100",
      "array"  => [1, 1.0, "1", true],
      "hash"   => {
        "code" => 200,
        "msg"  => "success",
      },
    }.to_json)
  end

  it "#merge!" do
    jbuilder = Jbuilder.new do |json|
      json.code "200"
      json.merge!({"code" => "400"})
    end
    jbuilder.to_json.should eq({
      "code" => "400",
    }.to_json)
  end
end
