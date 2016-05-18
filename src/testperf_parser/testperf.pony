use "debug"

interface Parser
  fun ref addData(data': Array[U8] box)
  fun ref run(): (ScanDone | ScanPaused | ScanError) ?

actor Main
  new create(env: Env) =>
    try
      var i: U32 = 0
      while i < 1000000 do
        _run(_ScannerState2.create())
        i = i + 1
      end
    else
      Debug.out("WAT?")
    end

  fun _run(p: Parser) ? =>
    p.addData("ab".array())
    var res = p.run()
    match res
    | let e: ScanError => Debug.out("ScanError : " + e.problem)
    | ScanPaused => Debug.out("ScanContinue")
    | ScanDone => Debug.out("ScanDone")
    end
    p.addData("c        ".array())
    res = p.run()
    match res
    | let e: ScanError => Debug.out("ScanError : " + e.problem)
    | ScanPaused => Debug.out("ScanContinue")
    | ScanDone => Debug.out("ScanDone")
    end
    p.addData("        ".array())
    res = p.run()
    match res
    | let e: ScanError => Debug.out("ScanError : " + e.problem)
    | ScanPaused => Debug.out("ScanContinue")
    | ScanDone => Debug.out("ScanDone")
    end
    p.addData("     d".array())
    res = p.run()
    match res
    | let e: ScanError => Debug.out("ScanError : " + e.problem)
    | ScanPaused => Debug.out("ScanContinue")
    | ScanDone => Debug.out("ScanDone")
    end
