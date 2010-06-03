begin
  # Needed to initialize these because rake tasks need constants to be
  # loaded

  class VotingMethod < ActiveRecord::Base
    include ConstantCache
    cache_constants :key => :display_name
  end

  class DistrictType < ActiveRecord::Base
    include ConstantCache
    cache_constants :key => :title
  end

  class Party < ActiveRecord::Base
    include ConstantCache
    cache_constants :key => :display_name
  end
rescue ActiveRecord::StatementInvalid => e
  # will throw an exception during db:migrate if any models are 
  # used when defining constants, because tables aren't created yet.
  # ignore this exception if in a rake task
  defined?(Rake) || throw(e)
end

