# Controller for viewing a file's blame
class Projects::BlobController < Projects::ApplicationController
  include ExtractsPath

  # Authorize
  before_filter :authorize_read_project!
  before_filter :authorize_code_access!
  before_filter :require_non_empty_project
  before_filter :authorize_push!, only: [:new, :create, :destroy]
  before_filter :require_branch_head, only: [:new, :create]
  before_filter :blob, except: [:new, :create]

  def show
  end

  def new
  end

  def create
    file_path = File.join(@path, File.basename(params[:file_name]))
    result = Files::CreateService.new(@project, current_user, params, @ref, file_path).execute

    if result[:status] == :success
      flash[:notice] = "Your changes have been successfully committed"
      redirect_to project_blob_path(@project, File.join(@ref, file_path))
    else
      flash[:alert] = result[:message]
      render :show
    end
  end

  def destroy
    result = Files::DeleteService.new(@project, current_user, params, @ref, @path).execute

    if result[:status] == :success
      flash[:notice] = "Your changes have been successfully committed"
      redirect_to project_tree_path(@project, @ref)
    else
      flash[:alert] = result[:error]
      render :show
    end
  end

  def diff
    @form = UnfoldForm.new(params)
    @lines = @blob.data.lines[@form.since - 1..@form.to - 1]

    if @form.bottom?
      @match_line = ''
    else
      lines_length = @lines.length - 1
      line = [@form.since, lines_length].join(',')
      @match_line = "@@ -#{line}+#{line} @@"
    end

    render layout: false
  end

  private

  def blob
    @blob ||= @repository.blob_at(@commit.id, @path)

    if @blob
      @blob
    elsif tree.entries.any?
      redirect_to project_tree_path(@project, File.join(@ref, @path)) and return
    else
      return not_found!
    end
  end
end
