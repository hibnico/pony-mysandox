use "debug"

class ScanError
  let problem: String

  new create(problem': String) =>
    problem = problem'

primitive ScanContinue
primitive ScanPaused
primitive ScanDone
type _ScanResult is (ScanContinue | ScanPaused | ScanError)

interface _Scanner
  fun ref scan(state: _ScannerState): _ScanResult ?

class _ScannerStack
  let _stack: Array[_Scanner] = Array[_Scanner].create(10)
  let _pos: USize = 0

  fun ref push(scanner: _Scanner) =>
    _stack.push(scanner)

  fun ref pop() =>
    try _stack.pop() end

  fun ref replace(scanner: _Scanner) =>
    try _stack.update(_stack.size() - 1, scanner) end

  fun ref peek(): (None | _Scanner) =>
    try
      _stack(_stack.size() - 1)
    else
      None
    end

class _WhitespaceScanner is _Scanner

  var nb: USize = 0

  fun ref scan(state: _ScannerState): _ScanResult ? =>
    if not state.available() then
      return ScanPaused
    end
    if state.check(' ') then
      nb = nb + 1
      state.skip()
    else
      state.scannerStack.pop()
    end
    ScanContinue


primitive _ScanRoot1
primitive _ScanRoot2
primitive _ScanRoot3
primitive _EndWhitespace

class _RootScanner is _Scanner

  var _state: (None | _ScanRoot1 | _ScanRoot2 | _ScanRoot3 | _EndWhitespace) = None
  var _whitespaceScanner: (None | _WhitespaceScanner) = None

  fun ref scan(state: _ScannerState): _ScanResult ? =>
    match _state
    | None => _startScan(state)
    | _ScanRoot1 => _scan1(state)
    | _ScanRoot2 => _scan2(state)
    | _EndWhitespace => _endWhitespace(state)
    | _ScanRoot3 => _scan3(state)
    else
      error
    end

  fun ref _startScan(state: _ScannerState): _ScanResult ? =>
    if not state.available() then
      return ScanPaused
    end
    if not state.check('a') then
      return ScanError("expecting a")
    end
    state.skip()
    Debug.out("a")
    _state = _ScanRoot1
    ScanContinue

  fun ref _scan1(state: _ScannerState): _ScanResult ? =>
    if not state.available() then
      return ScanPaused
    end
    if not state.check('b') then
      return ScanError("expecting b")
    end
    state.skip()
    Debug.out("b")
    _state = _ScanRoot2
    ScanContinue

  fun ref _scan2(state: _ScannerState): _ScanResult ? =>
    if not state.available() then
      return ScanPaused
    end
    if not state.check('c') then
      return ScanError("expecting c")
    end
    let s: _WhitespaceScanner ref = _WhitespaceScanner.create()
    _whitespaceScanner = s
    state.scannerStack.push(s)
    state.skip()
    Debug.out("c")
    _state = _EndWhitespace
    ScanContinue


  fun ref _endWhitespace(state: _ScannerState): _ScanResult ? =>
    let s = _whitespaceScanner as _WhitespaceScanner
    Debug.out("spaces = " + s.nb.string())
    _state = _ScanRoot3
    ScanContinue

  fun ref _scan3(state: _ScannerState): _ScanResult ? =>
    if not state.available() then
      return ScanPaused
    end
    if not state.check('d') then
      return ScanError("expecting d")
    end
    Debug.out("d")
    state.skip()
    state.scannerStack.pop()
    ScanContinue

class _ScannerState
  let scannerStack: _ScannerStack = _ScannerStack.create()
  let _data: Array[U8] ref = Array[U8].create(1024)
  var _pos: USize = 0

  new create() =>
    scannerStack.push(_RootScanner.create())

  fun ref addData(data': Array[U8] box) =>
    if _pos > 0 then
      _data.copy_to(_data, _pos, 0, _data.size() - _pos)
      _pos = 0
    end
    data'.copy_to(_data, 0, 0, data'.size())

  fun ref run(): (ScanDone | ScanPaused | ScanError) ?  =>
    match scannerStack.peek()
    | None => ScanDone
    | let s: _Scanner =>
      match s.scan(this)
      | ScanContinue => run()
      | ScanPaused => ScanPaused
      | let e: ScanError => e
      else
        error
      end
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
