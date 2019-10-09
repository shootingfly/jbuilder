require "./spec_helper"

describe Jbuilder do
  it "ember file" do
    io = IO::Memory.new
    Jbuilder.embed("spec/example.jbuilder", io).should be io
    io.to_s.should eq %({"null":null,"code":201,"msg":"ok","array1":[1,1.0,"1"],"array2":[{"code":1},{"code":2},{"code":3},{"code":4}],"data":{"code":400,"array3":[1,1.0,"1"]},"custom_field":["1","2"]})
  end
end
