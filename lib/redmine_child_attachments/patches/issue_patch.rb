# frozen_string_literal: true

module RedmineChildAttachments
  module Patches
    module IssuePatch
      extend ActiveSupport::Concern

      # Returns a scope of attachments from the issue itself and all its descendants.
      def all_attachments
        issue_ids = [id] + descendant_ids
        Attachment.where(container_type: 'Issue', container_id: issue_ids).order(Attachment.arel_table[:created_on])
      end

      private

      def descendant_ids
        # Using descendants.pluck(:id) can be faster as it avoids instantiating Issue objects.
        descendants.pluck(:id)
      end
    end
  end
end 
