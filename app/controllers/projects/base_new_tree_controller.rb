class Projects::BaseNewTreeController < Projects::BaseTreeController
  before_filter :require_branch_head
  before_filter :authorize_push_code!
end
