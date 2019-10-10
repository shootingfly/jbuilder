puts <<-Crystal
  Jbuilder.new do |json|
    #{File.read(ARGV[0])}
  end.to_json
Crystal
