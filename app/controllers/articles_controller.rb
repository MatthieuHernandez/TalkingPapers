class ArticlesController < ApplicationController
    require 'nokogiri'
    require 'open-uri'
    require 'uri'

    include ArticlesHelper

    def new
        render '/static_pages/home'
    end

    def create
        @url = format_url(article_params[:url])

        if article_params[:url].blank?
            if article_params[:is_arxiv] == 'true'
                redirect_to root_path(active_tab: 'arxiv') and return
            else
                redirect_to root_path(active_tab: 'others') and return
            end
        end
        
        @article = Article.where(:url => @url).first

        if @article.blank?
            if is_valid_arxiv_url
                create_article
            elsif is_valid_non_arxiv_url
                if @title.blank?
                    params[:active_tab] = 'others'
                    flash[:danger] = 'You must fill in the title of the article.'
                    redirect_to root_path(active_tab: 'others', url: @url) and return
                end
                create_article
            else
                if article_params[:is_arxiv] == 'true'
                   flash[:danger] = 'Invalid arxiv link, please check the arxiv URL and try again. (provide the link of abs page instead of the pdf if possible)'
                   redirect_to root_path(active_tab: 'arxiv') and return
                else
                   flash[:danger] = 'Invalid pdf link, please check the URL and try again.'
                   redirect_to root_path(active_tab: 'others') and return
                end
            end
        end
        redirect_to @article and return
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

    def format_url(url)
        url = url.delete(' ')
        if url.start_with?('arxiv.org')
            url.prepend('https://')
        end
        if url.include? 'arxiv.org/pdf/'
            url = url.gsub('.pdf', '')
            url = url.gsub('/pdf/', '/abs/')
        end
        if url.include? 'arxiv.org/ftp/arxiv/papers/'
            url = url.gsub('.pdf', '')
            url = url.gsub(/\/ftp\/arxiv\/papers\/[0-9]*\//, '/abs/')
        end
        return url
    end

    def is_valid_arxiv_url
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
        begin
            res = resolveUrl(@url)
            if res.code == '200' && res.content_type == 'application/pdf'
                @title = article_params[:title]
                @download_link = res['uri']
                return true
            end
        rescue
        end
        return false
    end

    def create_article
        @article = Article.new(:url => @url, :title => @title, :download_link => @download_link)
        @article.save
    end

end