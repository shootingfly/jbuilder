class Jbuilder
  # Registers partial templates whose first line declares their named locals.
  macro templates(root)
    {{ run("./template_compiler.cr", "partials", root) }}
  end

  macro embed(filename, io_name, layout_file = nil)
    {% if ::Jbuilder.resolve.has_constant?("TEMPLATE_ROOT") %}
      {% root = ::Jbuilder.resolve.constant("TEMPLATE_ROOT") %}
      {{ io_name.id }} << ({{ run("./template_compiler.cr", "embed", root, filename, layout_file || "", filename.filename || "") }}).to_json
    {% elsif layout_file %}
      {{ io_name.id }} << {{ read_file(layout_file).gsub(/yield_content/, read_file(filename)).id }}.to_json
    {% else %}
      {{ io_name.id }} << {{ run("./embedder.cr", filename) }}
    {% end %}
    {{ io_name.id }}
  end
end
