module ApplicationHelper

require 'kramdown'

    def kramdown(text)
        return Kramdown::Document.new(text).to_html.html_safe
    end

    def kramdown_title(text)
        title = text.dup
        title.gsub! '$', '$$'
        title = kramdown(title)
        title.gsub! '<p>', ''
        title.gsub! '</p>', ''
        title.gsub! "\n", ''
        return title
    end

    # Change the active tab.
    def is_active(*links)
        links.each { |link| return 'active' if params[:active_tab] == link }
    end

  # Returns the full title on a per-page basis.  # Documentation comment
    def full_title(page_title = '')              # Method def, optional arg
        base_title = "TalkingPapers"             # Variable assignment
        if page_title.empty?                     # Boolean test
            base_title                           # Implicit return
        else
            page_title + " | " + base_title      # String concatenation
        end
    end

    def will_paginate(collection_or_options = nil, options = {})
        if collection_or_options.is_a? Hash
            options, collection_or_options = collection_or_options, nil
        end
        unless options[:renderer]
            options = options.merge renderer: WillPaginate::ActionView::BootstrapLinkRenderer
        end
        super *[collection_or_options, options].compact
    end
end