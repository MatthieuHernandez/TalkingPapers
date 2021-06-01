class ArticlesController < ApplicationController
    require 'nokogiri'
    require 'open-uri'
    require 'uri'

    def new
        render '/static_pages/home'
    end

    def create
        #puts "---------- #{params[:active_tab]} ----------"
        #puts "URL = #{parse_arxiv_url(article_params[:url])}"

        @article = Article.where(:url => @article.url).first
        if exist.nil?
            if is_valid_arxiv_url(article_params[:url])
                create_arxiv_article
            elsif valid_non_arxiv_paper(article_params[:url])
                if params[:active_tab] == 'others'
                    create_non_arxiv_article
                else
                    redirect_to root_path (active_tab: 'others')
                end
            end
        end
        redirect_to @article
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

    def is_valid_arxiv_url(url)
        begin
            if url.include? "arxiv.org/abs/"
                doc = Nokogiri::HTML(open(@article.url))
                title = doc.xpath('/html/head/meta[@name="citation_title"]/@content').to_s
                download_link = doc.xpath('/html/head/meta[@name="citation_pdf_url"]/@content').to_s
                return url
            end
        rescue
            flash[:danger] = 'Invalid arxiv link, please check the arxiv URL and try again. (provide the link of abs page instead of the pdf if possible)'
            redirect_to root_path
        end
        return nil
    end

    def is_valid_non_arxiv_url(uri)
        begin
            url = URI.parse(uri)
            req = Net::HTTP.new(url.host, url.port)
            req.use_ssl = true
            res = req.request_head(url.path)
            if res.code == "200" && res.content_type == "application/pdf"
                article_params[:download_link] = uri
                true
            else
                false
            end
        rescue
            flash[:danger] = 'Invalid pdf link, please check the URL and try again.'
            redirect_to root_path
        end
    end

    def create_arxiv_article(url)
        title
        @article = Article.new(:url => article_params[:url], :title => article_params[:title], :download_link => article_params[:download_link])
        #@article.save
    end

    def create_non_arxiv_article(url)
        if title
        flash[:danger] = 'You must fill in the title of the article.'
        @article = Article.new(:url => article_params[:url], :title => article_params[:title], :download_link => article_params[:download_link])
        #@article.save
    end

end