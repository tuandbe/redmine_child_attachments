# frozen_string_literal: true

Redmine::Plugin.register :redmine_child_attachments do
  name 'Redmine Child Attachments'
  author 'Tuan ND (Hapo)'
  description 'This plugin displays attachments from child issues in the parent issue and allows embedding them.'
  version '1.0.0'
  requires_redmine version_or_higher: '5.0.0'

  # Load hooks and patches using absolute paths to ensure reliability during initialization.
  begin
    # Load hook for adding custom CSS to the page head
    require_dependency File.join(File.dirname(__FILE__), 'lib', 'redmine_child_attachments', 'hooks.rb')

    # Load the hook listener for displaying child attachments in a separate block.
    require_dependency File.join(File.dirname(__FILE__), 'lib', 'redmine_child_attachments', 'hooks_listener.rb')

    # Apply the Issue patch which adds the `all_attachments` method.
    issue_patch = File.join(File.dirname(__FILE__), 'lib', 'redmine_child_attachments', 'patches', 'issue_patch.rb')
    require_dependency issue_patch
    unless Issue.included_modules.include?(RedmineChildAttachments::Patches::IssuePatch)
      Issue.send(:include, RedmineChildAttachments::Patches::IssuePatch)
    end

    # Apply the Textile Helper patch for the default editor (when viewing saved content).
    textile_helper_patch = File.join(File.dirname(__FILE__), 'lib', 'redmine_child_attachments', 'patches', 'textile_helper_patch.rb')
    require_dependency textile_helper_patch
    unless Redmine::WikiFormatting::Textile::Helper.ancestors.include?(RedmineChildAttachments::Patches::TextileHelperPatch)
      Redmine::WikiFormatting::Textile::Helper.send(:prepend, RedmineChildAttachments::Patches::TextileHelperPatch)
    end

    # Apply the Markdown Helper patch for Markdown-based editors (like WYSIWYG).
    markdown_helper_patch = File.join(File.dirname(__FILE__), 'lib', 'redmine_child_attachments', 'patches', 'markdown_helper_patch.rb')
    require_dependency markdown_helper_patch
    unless Redmine::WikiFormatting::Markdown::Helper.ancestors.include?(RedmineChildAttachments::Patches::MarkdownHelperPatch)
      Redmine::WikiFormatting::Markdown::Helper.send(:prepend, RedmineChildAttachments::Patches::MarkdownHelperPatch)
    end

  rescue LoadError => e
    # This construction allows the plugin to function gracefully even if other plugins are missing.
    Rails.logger.error "Error loading RedmineChildAttachments plugin hooks or patches: #{e.message}"
  end
end
