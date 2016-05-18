
class ComputeSequence is ComputeElement
  let elements: Array[ComputeElement] val

  new val create(elements': Array[ComputeElement] val) =>
    elements = elements'

  fun createComputer(state: ComputeState, onResult: OnComputeResult): Computer ? =>
    elements(0).createComputer(state, _SequenceOnComputeResult(elements, onResult))

class _SequenceOnComputeResult is OnComputeResult
  let parentOnResult: OnComputeResult
  let elements: Array[ComputeElement] val
  var currentElement: USize = 0

  new create(elements': Array[ComputeElement] val, parentOnResult': OnComputeResult) =>
    elements = elements'
    parentOnResult = parentOnResult'

  fun ref onResult(res: ComputeResult): ComputeResult ? =>
    if res.status is ComputeFailed then
      return parentOnResult.onResult(res)
    end
    currentElement = currentElement + 1
    if currentElement < elements.size() then
      let parser = elements(currentElement).createParser(res.state, this)
      return ComputeResult.cont(res.state, parser)
    end
    parentOnResult.onResult(ComputeResult.success(res.state))
