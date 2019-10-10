require "json"
require "./jbuilder/version"
require "./jbuilder/embed"

class Jbuilder
  alias Integer = Int8 | Int16 | Int32 | Int64 | Int128 | UInt8 | UInt16 | UInt32 | UInt64 | UInt128
  alias BasicType = Bool | Float32 | Float64 | Integer | Nil | String | Time
  alias BasicObject = Array(BasicObject) | BasicType | Hash(String, BasicObject)

  def initialize(@result = Hash(String, BasicObject).new)
  end

  def self.new : Hash
    new.tap do |json|
      yield json
    end.to_h
  end

  macro method_missing(call)
    {% if call.block %}
      set!({{call.name.stringify}}, Jbuilder.new {{call.block}})
    {% else %}
      set!({{call.name.stringify}}, {{call.args.first}})
    {% end %}
  end

  def array!(key : String, array : Array)
    value = [] of BasicObject
    array.each do |item|
      value << item
    end
    @result[key] = value
  end

  def array!(key : String, array : Array)
    value = [] of BasicObject
    array.each do |item|
      value << Jbuilder.new do |json|
        yield json, item
      end
    end
    @result[key] = value
  end

  def hash!(key : String, hash : Hash)
    value = {} of String => BasicObject
    hash.each do |k, v|
      value[k] = v
    end
    @result[key] = value
  end

  def merge!(hash : Hash)
    @result.merge!(hash)
  end

  def set!(key : String, value : Array)
    array!(key, value)
  end

  def set!(key : String, value : Hash)
    hash!(key, value)
  end

  def set!(key : String, value : BasicType)
    @result[key] = value
  end

  def to_h : Hash
    @result
  end
end
