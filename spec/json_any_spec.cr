require "./spec_helper"

describe "native structured values" do
  it "renders nested parsed objects without changing scalar types" do
    source = JSON.parse(%({"items":[{"enabled":false,"value":null,"id":9223372036854775807}],"ratio":1.25,"text":"中文"}))
    rendered = Jbuilder.new do |json|
      json.document source
    end
    JSON.parse(rendered.to_json)["document"].should eq(source)
  end

  it "renders parsed arrays and hashes through field assignment" do
    source = JSON.parse(%({"items":[null,false,2,{"nested":["text"]}]}))
    rendered = Jbuilder.new do |json|
      json.items source["items"].as_a
      json.document source.as_h
    end
    parsed = JSON.parse(rendered.to_json)
    parsed["items"].should eq(source["items"])
    parsed["document"].should eq(source)
  end

  it "normalizes mixed containers through array and hash builders" do
    rendered = Jbuilder.new do |json|
      json.array!("items", [{flags: [JSON::Any.new(false)], pair: {nil, 1}}])
      json.hash!("options", {nested: {"values" => [JSON.parse(%({"enabled":true}))]}})
    end
    JSON.parse(rendered.to_json).should eq(JSON.parse(%({"items":[{"flags":[false],"pair":[null,1]}],"options":{"nested":{"values":[{"enabled":true}]}}})))
  end

  it "merges parsed values while preserving other fields and overwriting matching keys" do
    rendered = Jbuilder.new do |json|
      json.retained "before"
      json.items "replace"
      json.merge!(JSON.parse(%({"items":[null,false,{"name":"after"}]})).as_h)
    end
    JSON.parse(rendered.to_json).should eq(JSON.parse(%({"retained":"before","items":[null,false,{"name":"after"}]})))
  end

  it "keeps rendered containers independent from later source mutations" do
    source = JSON.parse(%({"items":[false]}))
    rendered = Jbuilder.new do |json|
      json.document source
    end
    source["items"].as_a << JSON::Any.new(true)
    JSON.parse(rendered.to_json)["document"]["items"].as_a.size.should eq(1)
  end
end
