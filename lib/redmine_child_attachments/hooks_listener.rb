# frozen_string_literal: true

module RedmineChildAttachments
  # This class contains the view hooks for the plugin.
  class HooksListener < Redmine::Hook::ViewListener
    # Renders a partial to display attachments from child issues.
    # The hook is placed at the bottom of the issue details view.
    def view_issues_show_details_bottom(context = {})
      issue = context[:issue]

      # We only want to render this on parent issues that have children.
      return unless issue.children.any?

      # Get attachments from descendants, excluding the current issue's own attachments.
      child_attachments = issue.all_attachments.reject { |a| a.container_id == issue.id }

      return if child_attachments.blank?

      # Prepare the data for the JSON script tag by manually constructing the download URL.
      # This is more reliable than trying to use a view helper from the controller context.
      attachments_json = child_attachments.map do |a|
        {
          id: a.id,
          name: a.filename,
          url: "/attachments/download/#{a.id}/#{ERB::Util.url_encode(a.filename)}"
        }
      end.to_json

      context[:controller].send(
        :render_to_string,
        partial: 'issues/child_attachments',
        locals: { attachments: child_attachments, attachments_json: attachments_json }
      )
    end

    # Adds the plugin's javascript to the page head.
    def view_layouts_base_html_head(context = {})
      stylesheet_link_tag('child_attachments.css', plugin: 'redmine_child_attachments') +
      javascript_include_tag('move_attachments.js', plugin: 'redmine_child_attachments')
    end
  end
end 
