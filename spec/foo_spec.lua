describe("some asserts", function()
  it("checks if they're equals", function()
    local expected = 1
    local obj = expected

    assert.are.equals(expected, obj)
  end)
end)
