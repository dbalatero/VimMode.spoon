local tableUtils = require("lib/utils/table")

describe("tableUtils", function()
  describe("#matches", function()
    local matches = tableUtils.matches

    it("returns true when two tables match", function()
      assert.are.equals(
        true,
        matches({'cmd'}, {'cmd'})
      )
    end)

    it("returns true when two tables are empty", function()
      assert.are.equals(
        true,
        matches({}, {})
      )
    end)

    it("returns true when two tables equal but out of order", function()
      assert.are.equals(
        true,
        matches({'shift', 'cmd'}, {'cmd', 'shift'})
      )
    end)

    it("returns false when two tables are not equal", function()
      assert.are.equals(
        false,
        matches({'cmd'}, {'cmd', 'shift'})
      )
    end)
  end)
end)
