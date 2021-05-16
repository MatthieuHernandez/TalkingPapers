class StaticPagesController < ApplicationController
  def home

    # @recent_notes = Note.where(is_public: true).limit(10).order('created_at desc')

    # @recent_articles = Article.find_by_sql("SELECT * FROM articles 
    #         INNER JOIN notes ON articles.id = notes.article_id 
    #         LIMIT 10")
    @recent_articles = Article.find_by_sql('''
      SELECT 
        article_id, 
        title, 
        url, 
        count(distinct notes.id) as num_notes,
        max(notes.created_at) as last_updated 
      from articles 
          inner join notes 
            on articles.id = notes.article_id 
      where
        notes.is_public
      group by 1,2,3
      order by last_updated desc 
      limit 10
            ''')
  end

  def help
  end

  def about
  end

  def contact
  end

  def display_article
  	render plain: params
  end
end
