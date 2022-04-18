class CommentsController < ApplicationController

    def new
        @note_id = params[:note_id]
    end

    def create
        @comment = current_user.comments.build(comment_params)
        @comment.update(note_id: params[:note_id])
        @comment.save
        redirect_to note_path(@comment.note_id)
    end

    def edit
        @comment = Comment.find(params[:id])
    end

    def update
        @comment = Comment.find(params[:id])
        @comment.update(comment_params)
        redirect_to note_path(@comment.note_id)
    end

    def destroy
        @comment = Comment.find(params[:id])
        @article = Article.find(@comment.note.article_id)
        if @comment.user_id == current_user.id
            @comment.destroy
            flash[:success] = "Comment deleted"
            if @comment.note.is_public
                redirect_to article_path(@article, query: "public")
            else
                redirect_to article_path(@article)
            end
        else
            redirect_to root_path
        end
    end


private
  def comment_params
    params.require(:comment).permit(:note_id, :user_id, :comment_text, :username, :is_anon)
  end

end
