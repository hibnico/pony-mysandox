use "debug"

interface ReifiedCallStack
  fun ref callStep(): CallResult
  fun ref callAll() =>
    var res: CallResult = callStep()
    while not (res is None) do
      try
        res = (res as ReifiedCallStack).callStep()
      end
    end

type CallResult is (ReifiedCallStack | None)

interface ReifiedCallback[R]
  fun iso onResult(r: R): CallResult


class SumAwait
  fun sum(add: AddAwait, n: U8): U8 =>
    if n == 0 then
      0
    else
      add.addAwait(sum(add, n-1), n)
    end

class AddAwait
  fun addAwait(i1: U8, i2: U8): U8 =>
    i1 + i2


interface iso AddOnResult
  fun onResult(r: U8)

actor Add
  be add(i1: U8, i2: U8, onResult: AddOnResult iso) =>
    onResult.onResult(i1 + i2)

class Sum is ReifiedCallStack
  var _n: U8
  var _caller: ReifiedCallback[U8] iso
  var _add: Add
  new create(add: Add, n': U8, caller': ReifiedCallback[U8] iso) =>
    Debug.out("Sum.create " + n'.string())
    _n = n'
    _add = add
    _caller = consume caller'
  fun ref callStep(): CallResult =>
    Debug.out("Sum.callStep " + _n.string())
    if _n == 0 then
      return _caller.onResult(0)
    end
    Sum(_add, _n-1, SumOnResult(_add, _n, _caller))


class SumOnResult is ReifiedCallback[U8]
  var _n: U8
  var _caller: ReifiedCallback[U8] iso
  var _add: Add
  new create(add: Add, n': U8, caller': ReifiedCallback[U8] iso) =>
    Debug.out("SumOnResult.create " + n'.string())
    _n = n'
    _add = add
    _caller = consume caller'
  fun iso onResult(r: U8): CallResult =>
    Debug.out("SumOnResult.onResult " + r.string())
    //_caller.onResult(r+_n)
    _add.add(r, _n, lambda (r2:U8)(_caller) => _caller.onResult(r2) end)



class FinalResult is ReifiedCallback[U8]
  var r: U8 = 0
  fun ref onResult(r': U8): CallResult =>
    Debug.out("FinalResult.onResult " + r'.string())
    r = r'
    None

actor Main
  new create(env: Env) =>
    var sumAwait: SumAwait = SumAwait.create()
    var addAwait: AddAwait = AddAwait.create()
    var res: U8 = sumAwait.sum(addAwait, 18)
    env.out.print(res.string())

    var finalResult: FinalResult ref = FinalResult.create()
    let add: Add = Add.create()
    var f: Sum = Sum(add, 18, finalResult)
    f.callAll()
    env.out.print(finalResult.r.string())
