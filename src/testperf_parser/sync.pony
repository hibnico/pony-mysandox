use "debug"

class SyncParser
  let _data: Array[U8] box
  var _pos: USize = 0

  new create(data': Array[U8] box) =>
    _data = data'

  fun ref run(): (ScanDone | ScanError) ?  =>
    match check('a')
    | let e: ScanError => return e
    end
    match check('b')
    | let e: ScanError => return e
    end
    match check('c')
    | let e: ScanError => return e
    end
    match countSpaces()
    | let e: ScanError => return e
    | let n: USize => Debug.out("spaces = " + n.string())
    end
    match check('d')
    | let e: ScanError => return e
    end
    ScanDone

  fun ref check(c: U8): (ScanDone | ScanError) ?  =>
    if _data(_pos) != c then
      return ScanError("expecting " + c.string())
    end
    _pos = _pos + 1
    Debug.out(c.string())
    ScanDone

  fun ref countSpaces(): (USize | ScanError) ?  =>
    var nb : USize = 0
    while _data(_pos) == ' ' do
      nb = nb + 1
      _pos = _pos + 1
    end
    nb
