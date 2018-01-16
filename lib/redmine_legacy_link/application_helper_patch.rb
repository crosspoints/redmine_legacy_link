require_dependency 'application_helper'

module ApplicationHelperPatch
  def parse_wiki_links(text, project, obj, attr, only_path, options)
    text.gsub!(/(!)?(\[\[([^\]\n\|]+)(\|([^\]\n\|]+))?\]\])/) do |m|
      link_project = project
      esc, all, page, title = $1, $2, $3, $5
      if esc.nil?
        if page =~ /^([^\:]+)\:(.*)$/
          identifier, page = $1, $2
          link_project = Project.find_by_identifier(identifier) || Project.find_by_name(identifier)
          title ||= identifier if page.blank?
        end

        if Setting.plugin_redmine_legacy_link['enable']
          link_flag = link_project && link_project.wiki
        else
          link_flag = link_project && link_project.wiki && User.current.allowed_to?(:view_wiki_pages, link_project)
        end
        if link_flag
          # extract anchor
          anchor = nil
          if page =~ /^(.+?)\#(.+)$/
            page, anchor = $1, $2
          end
          anchor = sanitize_anchor_name(anchor) if anchor.present?
          # check if page exists
          wiki_page = link_project.wiki.find_page(page)
          url = if anchor.present? && wiki_page.present? && (obj.is_a?(WikiContent) || obj.is_a?(WikiContent::Version)) && obj.page == wiki_page
            "##{anchor}"
          else
            case options[:wiki_links]
            when :local; "#{page.present? ? Wiki.titleize(page) : ''}.html" + (anchor.present? ? "##{anchor}" : '')
            when :anchor; "##{page.present? ? Wiki.titleize(page) : title}" + (anchor.present? ? "_#{anchor}" : '') # used for single-file wiki export
            else
              wiki_page_id = page.present? ? Wiki.titleize(page) : nil
              parent = wiki_page.nil? && obj.is_a?(WikiContent) && obj.page && project == link_project ? obj.page.title : nil
              url_for(:only_path => only_path, :controller => 'wiki', :action => 'show', :project_id => link_project,
               :id => wiki_page_id, :version => nil, :anchor => anchor, :parent => parent)
            end
          end

          if Setting.plugin_redmine_legacy_link['enable'] && Setting.plugin_redmine_legacy_link['only_link_name']
            if User.current.allowed_to?(:view_wiki_pages, link_project)
              link_to(title.present? ? title.html_safe : h(page), url, :class => ('wiki-page' + (wiki_page ? '' : ' new')))
            else
              title.present? ? title.html_safe : h(page)
            end
          else
            link_to(title.present? ? title.html_safe : h(page), url, :class => ('wiki-page' + (wiki_page ? '' : ' new')))
          end
        else
          # project or wiki doesn't exist
          all
        end
      else
        all
      end
    end
  end
end

module ApplicationHelper
  prepend ApplicationHelperPatch
end
