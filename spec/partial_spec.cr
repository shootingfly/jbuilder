require "./spec_helper"
require "file_utils"

Jbuilder.templates "spec/partial_views"

describe "partial templates with named locals" do
  it "renders nested partials on the current builder and retains false values" do
    io = IO::Memory.new
    Jbuilder.embed("spec/partial_views/root.jbuilder", io)
    io.to_s.should eq(%({"items":[{"name":"one","active":false},{"name":"two","active":false}],"after":"unchanged"}))
  end

  it "keeps partial locals separate from the caller and renders on a nested builder" do
    io = IO::Memory.new
    Jbuilder.embed("spec/partial_views/scope_root.jbuilder", io)
    io.to_s.should eq(%({"item":{"name":"INNER"},"name":"outer"}))
  end

  it "evaluates named arguments once and retains explicit null" do
    io = IO::Memory.new
    Jbuilder.embed("spec/partial_views/expressions.jbuilder", io)
    io.to_s.should eq(%({"name":"1","active":null,"calls":1}))
  end

  it "rejects missing partial arguments at compile time" do
    output = IO::Memory.new
    result = Process.run("crystal", ["build", "--no-codegen", "--no-color", "spec/partial_missing.cr"], output: output, error: output)
    result.success?.should be_false
    output.to_s.should contain("Invalid locals")
  end

  it "rejects extra partial arguments at compile time" do
    output = IO::Memory.new
    result = Process.run("crystal", ["build", "--no-codegen", "--no-color", "spec/partial_extra.cr"], output: output, error: output)
    result.success?.should be_false
    output.to_s.should contain("unexpected")
  end

  it "rejects unknown partial arguments at compile time" do
    output = IO::Memory.new
    result = Process.run("crystal", ["build", "--no-codegen", "--no-color", "spec/partial_unknown.cr"], output: output, error: output)
    result.success?.should be_false
    output.to_s.should contain("Unknown partial")
  end

  it "rejects dynamic partial arguments at compile time" do
    output = IO::Memory.new
    result = Process.run("crystal", ["build", "--no-codegen", "--no-color", "spec/partial_dynamic.cr"], output: output, error: output)
    result.success?.should be_false
    output.to_s.should contain("literal template path")
  end

  it "runs a compiled template without reading template files at runtime" do
    dir = File.tempname("jbuilder-partials")
    Dir.mkdir(dir)
    begin
      executable = File.join(dir, "partials")
      diagnostics = IO::Memory.new
      built = Process.run("crystal", ["build", "spec/partial_runtime.cr", "-o", executable], output: diagnostics, error: diagnostics)
      built.success?.should be_true, diagnostics.to_s
      output = IO::Memory.new
      Process.run(executable, chdir: dir, output: output).success?.should be_true
      output.to_s.should contain(%("name":"one"))
    ensure
      FileUtils.rm_rf(dir)
    end
  end
end
