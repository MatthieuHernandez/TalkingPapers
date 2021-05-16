class ArticlesController < ApplicationController
	require 'nokogiri'
	require 'open-uri'
	require 'uri'

	def new
		render '/static_pages/home'
	end

	def create

		if article_params[:is_arxiv] == "true"
	  		@article = Article.new(:url => article_params[:url], :title => article_params[:title], :download_link => article_params[:download_link])
	 	else
	 		@article = Article.new(:url => article_params[:url], :title => article_params[:title], :download_link => article_params[:url])
	 	end


		 # if not existing, create. else, just redirect
		existing = Article.where(:url => @article.url).first
		if existing.nil?
		  	  	
		  	  	if article_params[:is_arxiv] == "true"
		  	  	  	begin
			  	  	  	if @article.url.include? "arxiv.org/abs/" 
							  doc = Nokogiri::HTML(open(@article.url))
							  title = doc.xpath('/html/head/meta[@name="citation_title"]/@content').to_s
							  download_link = doc.xpath('/html/head/meta[@name="citation_pdf_url"]/@content').to_s


							  @article.update(title: title, download_link: download_link)

							  @article.save
							  redirect_to @article

						else
							flash[:danger] = 'Couldn\'t retrieve paper! Please check the arxiv URL (provide the abs page, not pdf link) and try again.'

						  	redirect_to root_path
						end

					rescue 
						flash[:danger] = 'Couldn\'t retrieve paper! Please check the arxiv URL (provide the abs page, not pdf link) and try again.'
						  
						redirect_to root_path
					end

				else
					if valid_non_arxiv_paper?(@article.url)

						if article_params[:title].delete(' ') != ""
							@article.save
							redirect_to @article
						else
							flash[:danger] = 'You must fill in the title of the article.'

							redirect_to root_path
						end
					else
						flash[:danger] = 'Invalid PDF link, please check and try again.'

						redirect_to root_path
					end
				end


		else
			redirect_to existing
		end

	end

	def show
		@article = Article.find(params[:id])
		if current_user.nil?
			@notes = nil
		else
			@notes = @article.notes.where(user_id: current_user.id, is_public: false)\
						.order(:page_num)
		end

		# @public_notes = @article.notes.where(is_public: true)\
		# 				.order(:page_num)
		# think need to modify this (find_by_sql) to include array of comments for each public note?

		@public_notes = Note.find_by_sql(['''
			select
				notes.id,
				notes.article_id,
				notes.page_num,
				notes.note_text,
				notes.note_type,
				notes.user_id,
				notes.is_public,
				notes.username,
				notes.is_anon,
				array_agg(comments.comment_text order by comments.created_at) comments_texts
			from
				notes
					inner join articles
						on (articles.id = notes.article_id)
					left join comments
						on (notes.id = comments.note_id)
			where
				articles.id = ?
				and notes.is_public
			group by
				1,2,3,4,5,6,7,8,9
			order by
				page_num
		''', params[:id]])

		@query = params[:query]
	end
 
private
  def article_params
    params.require(:article).permit(:url, :title, :download_link, :is_arxiv)
  end

  def valid_non_arxiv_paper?(uri)
	  begin
		url = URI.parse(uri)
		req = Net::HTTP.new(url.host, url.port)
		req.use_ssl = true
		res = req.request_head(url.path)
	    if res.code == "200" && res.content_type == "application/pdf"
	    	true
	    else
	    	false
	    end
	  rescue
	    false
	  end
  end

end