class Jbuilder
  macro embed(filename, io_name, layout_file = nil)
    {% if layout_file %}
      {{ io_name.id }} << {{ read_file(layout_file).gsub(/yield_content/, read_file(filename)).id }}.to_json
      {{ io_name.id }}
    {% else %}
      {{ io_name.id }} << {{ run("./embedder.cr", filename) }}
      {{ io_name.id }}
    {% end %}
  end
end
