local visualUtils = {}

-- Given a `currentRange` selected, and a new `motionRange` to add to the
-- selection, and a `caretPosition` tracked separate from the selection,
-- calculate the new caret position and a new range that merges the 2
-- together
visualUtils.getNewRange = function (currentRange, motionRange, caretPosition)
  local noSelection = currentRange.start == currentRange.finish

  local caretOn = (caretPosition < currentRange.finish and "left") or "right"
  local motionDirection = "right"

  if currentRange.finish == motionRange.finish or
     currentRange.start == motionRange.finish then
    motionDirection = "left"
  end

  if noSelection then
    return {
      caretPosition =
        (motionDirection == "left" and motionRange.start) or motionRange.finish,
      range = motionRange
    }
  end

  local newRange = {
    start = currentRange.start,
    finish = currentRange.finish,
  }

  local key = (caretOn == "left" and "start") or "finish"
  local newValue =
    (motionDirection == "left" and motionRange.start) or motionRange.finish

  newRange[key] = newValue

  return {
    caretPosition = newRange[key],
    range = newRange
  }
end

return visualUtils
