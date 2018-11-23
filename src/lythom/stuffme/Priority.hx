package lythom.stuffme;

@:enum
abstract Priority(Int) {
    var Normal = 0;
    var After = 1;
    var Finally = 2;
}
