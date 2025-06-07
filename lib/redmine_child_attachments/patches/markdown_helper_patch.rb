# frozen_string_literal: true

module RedmineChildAttachments
  module Patches
    # This patch is for Redmine's Markdown formatting helper.
    # It ensures that attachments from child issues can be resolved and displayed
    # when using Markdown syntax like ![](filename.jpg).
    module MarkdownHelperPatch
      extend ActiveSupport::Concern

      included do
        # We need to find the attachment by its filename across all child issues
        # and then generate the correct URL for it.
        # Overriding `inline_attachments` is still the right place.
        prepend(InstanceMethods)
      end

      module InstanceMethods
        def inline_attachments(text)
          # If the object being rendered is an Issue, we temporarily expand its
          # `attachments` method to include all attachments from descendants.
          # This allows the formatter to find the attachment object by its filename.
          if @obj.is_a?(Issue) && @obj.respond_to?(:all_attachments)
            @obj.define_singleton_method(:attachments) do
              all_attachments
            end
          end

          # Now, call the original method. It will find the attachment object
          # from the combined list and generate the correct download URL for it.
          super
        ensure
          # After rendering, we must clean up the temporary method to prevent side effects.
          if @obj.is_a?(Issue) && @obj.singleton_class.method_defined?(:attachments)
            @obj.singleton_class.send(:undef_method, :attachments)
          end
        end
      end
    end
  end
end 
