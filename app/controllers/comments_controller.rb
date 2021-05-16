class CommentsController < ApplicationController

	def new
		@note_id = params[:note_id]
	end

	def create
    	@comment = current_user.comments.build(comment_params)

		@comment.update(note_id: params[:note_id])

		@comment.save

		redirect_to note_path(params[:note_id])
	end


private
  def comment_params
    params.require(:comment).permit(:note_id, :user_id, :comment_text, :username, :is_anon)
  end

end
