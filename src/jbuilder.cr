require "json"
require "./jbuilder/version"
require "./jbuilder/embed"

class Jbuilder
  alias Integer = Int8 | Int16 | Int32 | Int64 | Int128 | UInt8 | UInt16 | UInt32 | UInt64 | UInt128
  alias BasicType = Bool | Float32 | Float64 | Integer | Nil | String | Time
  alias BasicObject = Array(BasicObject) | BasicType | Hash(String, BasicObject)

  def initialize(@result = Hash(String, BasicObject).new)
  end

  def self.new(&) : Hash
    new.tap do |json|
      yield json
    end.to_h
  end

  macro method_missing(call)
    {% raise "Values only allowed Array | Tuple | Hash | NamedTuple | #{BasicType}" if call.name.stringify.ends_with?("!") %} 

    {% if call.block %}
      set!({{call.name.stringify}}, Jbuilder.new {{call.block}})
    {% else %}
      set!({{call.name.stringify}}, {{call.args.first}})
    {% end %}
  end

  def array!(key : String, array)
    value = [] of BasicObject
    array.each do |item|
      value << native_value(item)
    end
    @result[key] = value
  end

  def array!(key : String, array, &)
    value = [] of BasicObject
    array.each do |item|
      value << Jbuilder.new do |json|
        yield json, item
      end
    end
    @result[key] = value
  end

  def hash!(key : String, hash)
    value = {} of String => BasicObject
    hash.each do |k, v|
      value[k.to_s] = native_value(v)
    end
    @result[key] = value
  end

  def merge!(hash : Hash)
    hash.each { |key, value| @result[key.to_s] = native_value(value) }
    @result
  end

  def set!(key : String, value : Array)
    array!(key, value)
  end

  def set!(key : String, value : Tuple)
    array!(key, value.to_a)
  end

  def set!(key : String, value : Hash)
    hash!(key, value)
  end

  def set!(key : String, value : NamedTuple)
    hash!(key, value.to_h)
  end

  def set!(key : String, value : BasicType)
    @result[key] = value
  end

  def set!(key : String, value : JSON::Any)
    @result[key] = native_value(value)
  end

  private def native_value(value : JSON::Any) : BasicObject
    native_value(value.raw)
  end

  private def native_value(value : BasicType) : BasicObject
    value
  end

  private def native_value(values : Array | Tuple) : BasicObject
    items = [] of BasicObject
    values.each { |value| items << native_value(value) }
    items
  end

  private def native_value(values : Hash | NamedTuple) : BasicObject
    fields = {} of String => BasicObject
    values.each { |key, value| fields[key.to_s] = native_value(value) }
    fields
  end

  def to_h : Hash
    @result
  end
end
