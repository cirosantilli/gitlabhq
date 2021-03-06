module MergeRequests
  class BaseService < IssuableBaseService

    def create_note(merge_request)
      Note.create_status_change_note(merge_request, merge_request.target_project, current_user, merge_request.state, nil)
    end

    def execute_hooks(merge_request)
      if merge_request.project
        merge_request.project.execute_hooks(merge_request.to_hook_data, :merge_request_hooks)
      end
    end
  end
end
