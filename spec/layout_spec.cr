require "./spec_helper"

describe Jbuilder do
  it "embeds file without layout" do
    io = IO::Memory.new
    Jbuilder.embed(
      "spec/dummy/views/users/index.jbuilder",
      io
    ).should be io
    io.to_s.should eq %({"token":"abc","users":[{"nick_name":"Tom"},{"nick_name":"Lisa"}]})
  end

  it "embeds file with layout" do
    io = IO::Memory.new
    Jbuilder.embed(
      "spec/dummy/views/users/index.jbuilder",
      io,
      "spec/dummy/views/layouts/application.jbuilder"
    ).should be io
    io.to_s.should eq %({"code":"200","msg":"ok","data":{"token":"abc","users":[{"nick_name":"Tom"},{"nick_name":"Lisa"}]}})
  end
end
