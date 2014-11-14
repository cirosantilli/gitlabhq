class Projects::UploadTreeController < Projects::BaseNewTreeController
  def show
  end

  def update
    params.each do |file|
      file_path = File.join(@path, File.basename(params[:file_name]))
      result = Files::CreateService.new(@project, current_user, params, @ref, file_path).execute
    end
    redirect_path = project_blob_path(@project, File.join(@ref, file_path))
    changes_successful_action(result, redirect_path)
  end
end
