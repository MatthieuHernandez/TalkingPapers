class ArticlesController < ApplicationController
    require 'nokogiri'
    require 'open-uri'
    require 'uri'

    def new
        render '/static_pages/home'
    end

    def create
        @url = article_params[:url]
        active_tab = params[:active_tab]
        @article = Article.where(:url => @url).first

        if @article.blank?
            if is_valid_arxiv_url
                puts "Arxiv paper"
                create_arxiv_article
            elsif is_valid_non_arxiv_url
                puts "Non arxiv paper"
                puts "title = #{@title}"
                if @title.blank?
                    params[:active_tab] = 'others'
                    flash[:danger] = 'You must fill in the title of the article.'
                    redirect_to root_path(active_tab: 'others') and return
                end
                # if active_tab == 'others'
                #     puts "Non arxiv paper"
                #     create_non_arxiv_article
                # else
                #     flash[:success] = 'Error'
                #     redirect_to root_path and return
                #     redirect_to root_path(active_tab: 'others')
                # end
            else
                if article_params[:is_arxiv] == 'true'
                   flash[:danger] = 'Invalid arxiv link, please check the arxiv URL and try again. (provide the link of abs page instead of the pdf if possible)'
                else
                   flash[:danger] = 'Invalid pdf link, please check the URL and try again.'
                end
                redirect_to root_path and return
                return
            end
        end
        flash[:success] = 'Article created'
        redirect_to root_path and return
        #puts "Blank = #{@article.blank?}"
        #return redirect_to @article
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
        #                 .order(:page_num)
        # think need to modify this (find_by_sql) to include array of comments for each public note?

        @public_notes = Note.find_by_sql(['''
SELECT
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
FROM
    notes
    INNER JOIN articles
        ON articles.id = notes.article_id
    LEFT JOIN comments
        ON notes.id = comments.note_id
WHERE
    articles.id = ?
    and notes.is_public
GROUP BY
    1,2,3,4,5,6,7,8,9
ORDER BY
    page_num''', params[:id]])

        @query = params[:query]
    end

private

    def article_params
        params.require(:article).permit(:url, :title, :download_link, :is_arxiv)
    end

    def is_valid_arxiv_url
        puts '===> is_valid_arxiv_url'
        begin
            if @url.include? 'arxiv.org/abs/'
                doc = Nokogiri::HTML(open(@url))
                @title = doc.xpath('/html/head/meta[@name="citation_title"]/@content').to_s
                @download_link = doc.xpath('/html/head/meta[@name="citation_pdf_url"]/@content').to_s
                return true
            end
        end
        return false
    end

    def is_valid_non_arxiv_url
        puts '===> is_valid_non_arxiv_url'
        begin
            uri  = URI.parse(@url)
            req = Net::HTTP.new(uri.host, uri.port)
            res = req.request_head(uri.path)
            if res.code == "200" && res.content_type == "application/pdf"
                @title = article_params[:title]
                @download_link = @url
                return true
            end
        rescue
            return false
        end
        return false
    end

    def create_arxiv_article
        puts '---------- create_arxiv_article ----------'
        puts "url           = #{@url}"
        puts "title         = #{@title}"
        puts "download_link = #{@download_link}"
        puts '------------------------------------------'
        #@article = Article.new(:url => article_params[:url], :title => article_params[:title], :download_link => article_params[:download_link])
        #@article.save
    end

    def create_non_arxiv_article
        puts '-------- create_non_arxiv_article --------'
        puts "url           = #{@url}"
        puts "title         = #{@title}"
        puts "download_link = #{@download_link}"
        puts '------------------------------------------'
        # if article_params[:title].blank?
        #     flash[:danger] = 'You must fill in the title of the article.'
        #     redirect_to root_path
        # end
        # @article = Article.new(:url => article_params[:url], :title => article_params[:title], :download_link => article_params[:download_link])
        # @article.save
    end

end