class Jbuilder
  macro embed(filename, io_name)
    {{ io_name.id }} << {{ run("./embedder.cr", filename) }}
    {{ io_name.id }}
  end
end
