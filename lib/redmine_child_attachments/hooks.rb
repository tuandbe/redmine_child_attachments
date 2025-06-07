module RedmineChildAttachments
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(_context = {})
      stylesheet_link_tag('child_attachments', plugin: 'redmine_child_attachments')
    end
  end
end 
