use "debug"

interface Parser
  fun ref addData(data': Array[U8] box)
  fun ref run(): (ScanDone | ScanPaused | ScanError) ?

actor Main
  new create(env: Env) =>
    try
      var i: U32 = 0
      while i < 1000000 do

        // state verion
        // _run(_ScannerState.create())

        // callback version
        _run(_ScannerState2.create())

        // sync version
        //run_sync()

        i = i + 1
      end
    else
      Debug.out("WAT?")
    end

  fun _run(p: Parser) ? =>
    p.addData("ab".array())
    match p.run()
    | let e: ScanError => Debug.out("ScanError : " + e.problem)
    | ScanPaused => Debug.out("ScanContinue")
    | ScanDone => Debug.out("ScanDone")
    end
    p.addData("c        ".array())
    match p.run()
    | let e: ScanError => Debug.out("ScanError : " + e.problem)
    | ScanPaused => Debug.out("ScanContinue")
    | ScanDone => Debug.out("ScanDone")
    end
    p.addData("        ".array())
    match p.run()
    | let e: ScanError => Debug.out("ScanError : " + e.problem)
    | ScanPaused => Debug.out("ScanContinue")
    | ScanDone => Debug.out("ScanDone")
    end
    p.addData("     d".array())
    match p.run()
    | let e: ScanError => Debug.out("ScanError : " + e.problem)
    | ScanPaused => Debug.out("ScanContinue")
    | ScanDone => Debug.out("ScanDone")
    end

  fun run_sync() ? =>
    match SyncParser.create("abc                      d".array()).run()
    | let e: ScanError => Debug.out("ScanError : " + e.problem)
    | ScanDone => Debug.out("ScanDone")
    end
