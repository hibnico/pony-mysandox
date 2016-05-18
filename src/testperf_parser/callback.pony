use "debug"

interface _Scanner2
  fun ref scan(state: _ScannerState2): _ScanResult2 ?

type _ScanResult2 is (ScanPaused | _Scanner2 | ScanDone | ScanError)



class _AScanner is _Scanner2

  fun ref scan(state: _ScannerState2): _ScanResult2 ? =>
    if not state.available() then
      return ScanPaused
    end
    if not state.check('a') then
      return ScanError("expecting a")
    end
    state.skip()
    Debug.out("a")
    _BScanner

class _BScanner is _Scanner2

  fun ref scan(state: _ScannerState2): _ScanResult2 ? =>
    if not state.available() then
      return ScanPaused
    end
    if not state.check('b') then
      return ScanError("expecting b")
    end
    state.skip()
    Debug.out("b")
    _CScanner

class _CScanner is _Scanner2

  fun ref scan(state: _ScannerState2): _ScanResult2 ? =>
    if not state.available() then
      return ScanPaused
    end
    if not state.check('c') then
      return ScanError("expecting c")
    end
    state.skip()
    Debug.out("c")
    _WhitespaceScanner2.create(
      lambda(s: _WhitespaceScanner2): _ScanResult2 =>
        Debug.out("spaces = " + s.nb.string())
        _DScanner
      end
    )

class _WhitespaceScanner2 is _Scanner2

  var nb: USize = 0
  let _onResult: {(_WhitespaceScanner2): _ScanResult2} val

  new create(onResult: {(_WhitespaceScanner2): _ScanResult2} val) =>
    _onResult = onResult

  fun ref scan(state: _ScannerState2): _ScanResult2 ? =>
    while true do
      if not state.available() then
        return ScanPaused
      end
      if not state.check(' ') then
        return _onResult.apply(this)
      end
      nb = nb + 1
      state.skip()
    end
    ScanPaused // well, after a while true...

class _DScanner is _Scanner2

  fun ref scan(state: _ScannerState2): _ScanResult2 ? =>
    if not state.available() then
      return ScanPaused
    end
    if not state.check('d') then
      return ScanError("expecting d")
    end
    Debug.out("d")
    ScanDone





class _ScannerState2
  var _scanner: _Scanner2 = _AScanner
  let _data: Array[U8] ref = Array[U8].create(1024)
  var _pos: USize = 0

  fun ref addData(data': Array[U8] box) =>
    if _pos > 0 then
      _data.copy_to(_data, _pos, 0, _data.size() - _pos)
      _pos = 0
    end
    data'.copy_to(_data, 0, 0, data'.size())

  fun ref run(): (ScanDone | ScanPaused | ScanError) ?  =>
    match _scanner.scan(this)
    | let s: _Scanner2 => _scanner = s; run()
    | ScanPaused => ScanPaused
    | let e: ScanError => e
    | ScanDone => ScanDone
    else
      error
    end

  fun available(nb: USize = 1): Bool =>
    (_data.size() - _pos) >= nb

  /*
   * Check the current octet in the buffer.
   */
  fun check(char: U8, offset: USize = 0): Bool ? =>
    _data(_pos + offset) == char

  fun ref skip() =>
    _pos = _pos + 1
