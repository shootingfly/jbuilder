require "../src/jbuilder"
Jbuilder.templates "spec/partial_views"
io = IO::Memory.new
Jbuilder.embed("spec/partial_views/invalid_dynamic.jbuilder", io)
