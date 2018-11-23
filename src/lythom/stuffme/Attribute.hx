package lythom.stuffme;

@:keep
abstract Attribute(String) from String to String {
  public inline function new(name) {
    this = name;
  }
}