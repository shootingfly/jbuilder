require "../src/jbuilder"
Jbuilder.templates "spec/partial_views"
Jbuilder.embed("spec/partial_views/root.jbuilder", STDOUT)
