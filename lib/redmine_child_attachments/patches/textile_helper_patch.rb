# frozen_string_literal: true

module RedmineChildAttachments
  module Patches
    module TextileHelperPatch
      extend ActiveSupport::Concern

      included do
        prepend(InstanceMethods)
      end

      module InstanceMethods
        def inline_attachments(text)
          # Temporarily override attachments for the object being rendered (@obj)
          # if it's an issue, so the macro can find child attachments.
          if @obj.is_a?(Issue) && @obj.respond_to?(:all_attachments)
            @obj.define_singleton_method(:attachments) do
              all_attachments
            end
          end
          # Call the original method, which will now use our temporary override.
          super
        ensure
          # Clean up the temporary method to prevent side effects.
          if @obj.is_a?(Issue) && @obj.singleton_class.method_defined?(:attachments)
            @obj.singleton_class.send(:undef_method, :attachments)
          end
        end
      end
    end
  end
end 
