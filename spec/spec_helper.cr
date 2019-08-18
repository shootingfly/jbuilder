require "spec"
require "../src/jbuilder"

struct UserCase
  property id : Int64
  property nick_name : String
  property email : String
  property age : Int32
  property is_male : Bool
  property created_at : Time
  property hobbits : Array(String)

  def initialize(
    @id : Int64,
    @nick_name : String,
    @email : String,
    @age : Int32,
    @is_male : Bool,
    @created_at : Time,
    @hobbits : Array(String)
  )
  end
end
