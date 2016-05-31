use "debug"

actor Main
  new create(env: Env) =>
    try
      let data = InputData.create("test data".array())
      let wordParser1: WordParser ref = WordParser.create()
      wordParser1.parse(data)
      Debug.out("1. " + wordParser1.getWord())
      data.skip()
      let wordParser2: WordParser ref = WordParser.create()
      wordParser2.parse(data)
      Debug.out("2. " + wordParser2.getWord())
    else
      Debug.out("WAT")
    end

class InputData
  let data: Array[U8] val
  var pos: USize = 0

  new create(data': Array[U8] val) =>
    data = data'

  fun available(): Bool =>
    pos < data.size()

  fun check(c: U8): Bool ? =>
    c == data(pos)

  fun ref skip() =>
    pos = pos + 1

  fun ref read(s: String trn): String trn^ ? =>
    let char = data(pos)
    if (char and 0x80) == 0x00 then
      s.push(char)
      pos = pos + 1
    elseif (char and 0xE0) == 0xC0 then
      s.push(char)
      s.push(data(pos + 1))
      pos = pos + 2
    elseif (char and 0xF0) == 0xE0 then
      s.push(char)
      s.push(data(pos + 1))
      s.push(data(pos + 2))
      pos = pos + 2
    elseif (char and 0xF8) == 0xF0 then
      s.push(char)
      s.push(data(pos + 1))
      s.push(data(pos + 2))
      s.push(data(pos + 3))
      pos = pos + 3
    else
      error
    end
    consume s

class WordParser
  var word: (None | String trn) = recover String.create() end

  fun ref parse(data: InputData) ? =>
    while data.available() do
      if data.check(' ') then
        return
      end
      word = data.read((word = None) as String trn^)
    end

  fun ref getWord(): String val ? =>
    (word = None) as String trn^
