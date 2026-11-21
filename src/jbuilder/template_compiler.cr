# Build-time compiler. Generated templates have no filesystem or parser dependency at runtime.
require "compiler/crystal/syntax"
require "compiler/crystal/syntax/transformer"
require "digest/sha256"

private class PartialTemplates < Crystal::Transformer
  getter templates = {} of String => Tuple(String, Array(String))

  def initialize(root : String)
    return if root.empty?
    Dir.glob(File.join(root, "**/*.jbuilder")).sort.each do |file|
      source = File.read(file)
      next unless header = source.lines.first?.try(&.match(/\A# locals:\s*(.*?)\s*\z/))
      names = header[1].split(',').map(&.strip).reject(&.empty?)
      unless names.uniq.size == names.size && names.all? { |name| /\A[a-z_][a-z0-9_]*\z/.matches?(name) && name != "json" }
        raise "Invalid partial locals in #{file}"
      end
      key = Path[file].relative_to(root).to_s.sub(/\.jbuilder\z/, "")
      @templates[key] = {file, names}
    end
  end

  def method_name(key : String) : String
    "__jbuilder_partial_" + key.gsub(/[^a-zA-Z0-9_]/, "_") + "_" + Digest::SHA256.hexdigest(key)[0, 8]
  end

  def transform(node : Crystal::Call) : Crystal::ASTNode
    node = super.as(Crystal::Call)
    return node unless node.name == "partial!"
    literal = node.args.first?.as?(Crystal::StringLiteral)
    unless literal && node.args.size == 1 && node.obj && !node.block && !node.block_arg
      raise "partial! requires a literal template path and named locals"
    end
    key = literal.value.sub(/\.jbuilder\z/, "")
    template = @templates[key]? || raise "Unknown partial #{key.inspect}; register it with Jbuilder.templates and declare # locals:"
    supplied = (node.named_args || [] of Crystal::NamedArgument).map(&.name)
    expected = template[1]
    unless supplied.sort == expected.sort
      missing = expected - supplied
      extra = supplied - expected
      raise "Invalid locals for #{key.inspect}: missing #{missing}, unexpected #{extra}"
    end
    node.name = method_name(key)
    node.args.clear
    node
  end

  def compile(source : String, filename : String, locals = [] of String) : String
    parser = Crystal::Parser.new(source, nil, [(locals + ["json"]).to_set])
    parser.filename = filename unless filename.empty?
    parser.parse.transform(self).to_s
  end
end

begin
  mode, root = ARGV[0], ARGV[1]
  compiler = PartialTemplates.new(root)
  if mode == "partials"
    puts "class ::Jbuilder"
    puts "TEMPLATE_ROOT = #{root.inspect}"
    compiler.templates.each do |key, (file, names)|
      params = names.empty? ? "" : "*, " + names.join(", ")
      puts "def #{compiler.method_name(key)}(#{params}) : self"
      puts "json = self"
      puts compiler.compile(File.read(file), File.expand_path(file), names)
      puts "self\nend"
    end
    puts "end"
  elsif mode == "embed"
    source = File.read(ARGV[2])
    layout = ARGV[3]
    program = if layout.empty?
                "Jbuilder.new do |json|\n#{source}\nend"
              else
                File.read(layout).gsub("yield_content", source)
              end
    puts compiler.compile(program, ARGV[4])
  else
    raise "Unknown template compiler mode: #{mode}"
  end
rescue error
  STDERR.puts(error.message)
  exit 1
end
