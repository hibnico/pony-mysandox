
class ScanError
  let problem: String
  let context: String

  new create(problem': String, context': String) =>
    problem = problem'
    context = context'

primitive ScanDone
primitive ScanPaused
type _ScanResult is (ScanDone | ScanPaused | ScanError | _ScannerClass | _ScannerFunc)

interface _ScannerClass
  fun ref scan(state: _ScannerState): _ScanResult ?

type _ScannerFunc is {(_ScannerState ref): _ScanResult ? } ref

type _Scanner is (_ScannerClass | _ScannerFunc)

class _ScannerState
  // [...]


class _TagScanner
  let _nextScanner: _Scanner

  new create(nextScanner: _Scanner) =>
    _nextScanner = nextScanner

  fun ref scan(state: _ScannerState): _ScanResult ? =>
    _TagURIScanner.create(this~_scanEndUri())

  fun ref _scanEndUri(state: _ScannerState): _ScanResult ? =>
    if false then
      error
    end
    _nextScanner

class _TagURIScanner
 let _nextScanner: _Scanner

 new create(nextScanner: _Scanner) =>
   _nextScanner = nextScanner

 fun ref scan(state: _ScannerState): _ScanResult ? =>
   if false then
     error
   end
   _nextScanner
