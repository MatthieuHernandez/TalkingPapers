class NotesController < ApplicationController

	def new
	end

	def create
    	@note = current_user.notes.build(note_params)
    	@note.image.attach(params[:note][:image])

		@note.update(article_id: params[:article_id])
		# add image copying here
		if !params[:note][:parent_note_id].nil? && Note.find(params[:note][:parent_note_id]).image.attached?
			@note.image.attach(Note.find(params[:note][:parent_note_id]).image.blob)
		end

		@note.save

		redirect_to article_path(params[:article_id])
	end

	def show
		@note = Note.find(params[:id])
		@note_comments = Comment.where(note_id: params[:id]).order(:created_at)

		if !@note.is_public
			redirect_to root_path
		end


	end

	def destroy
		@note = Note.find(params[:id])
		if @note.user_id == current_user.id
	    	@note.destroy
	    	flash[:success] = "Note deleted"
	    	redirect_to article_path(id: params[:article_id], query: params[:query])
	    else
	    	redirect_to root_path
	    end
	end

	def edit
		@article = Article.find(params[:article_id])
		@note = Note.find(params[:id])
	end

	def update
	    @note = Note.find(params[:id])
	    if @note.update(note_params)
	      flash[:success] = "Note updated"
	      redirect_to article_path(params[:article_id])
	    else
	      render 'edit'
	    end
	end

private
  def note_params
    params.require(:note).permit(:article_id, :note_text, :user_id, 
    	:is_public, :note_type, :page_num, :username, :is_anon, :image, :parent_note_id)
  end

end
