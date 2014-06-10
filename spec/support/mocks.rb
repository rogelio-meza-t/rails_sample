module MockSupport
  def during(&block)
    @_deferred_execution_block = block
    self
  end

  def behold!
    yield
    @result = @_deferred_execution_block.call
  end
end

# This rigamarole with a module is needed to avoid
# having the methods end up as privates called from
# a different scope. 
include MockSupport
