// This script performs several functions:
// 1. Moves the child attachments block after the subtasks block.
// 2. Merges child attachments into the WYSIWYG editor's attachment list.
// 3. Adds click handlers to "Insert" links to insert attachment syntax into the editor.

function moveChildAttachmentsBlock() {
  const childAttachmentsSection = document.getElementById('child-attachments-section');
  if (!childAttachmentsSection) return;

  const issueTreeSection = document.getElementById('issue_tree');
  if (issueTreeSection) {
    issueTreeSection.after(childAttachmentsSection);
  }
}

function updateWysiwygAttachments() {
  const childAttachmentsDataElement = document.getElementById('child-attachments-json-data');
  if (!childAttachmentsDataElement) return;

  const childAttachments = JSON.parse(childAttachmentsDataElement.textContent);
  if (!childAttachments || childAttachments.length === 0) return;

  const interval = setInterval(function() {
    if (typeof redmineWysiwygEditorManager !== 'undefined' && redmineWysiwygEditorManager.editors.length > 0) {
      clearInterval(interval);
      redmineWysiwygEditorManager.editors.forEach(function(editor) {
        if (editor.addAttachments) {
          editor.addAttachments(childAttachments);
        }
      });
    }
  }, 200);
}

function setupInsertAttachmentLinks() {
  const childAttachmentsDataElement = document.getElementById('child-attachments-json-data');
  if (!childAttachmentsDataElement) return;
  const childAttachments = JSON.parse(childAttachmentsDataElement.textContent);

  document.getElementById('child-attachments-section').addEventListener('click', function(event) {
    if (event.target.classList.contains('insert-attachment-link')) {
      event.preventDefault();
      const link = event.target;
      const attachmentId = parseInt(link.dataset.attachmentId, 10);
      const attachmentData = childAttachments.find(a => a.id === attachmentId);
      if (!attachmentData) {
        console.error('[Child Attachments] Could not find attachment data for ID:', attachmentId);
        return;
      }

      // Define both HTML and Plain Text syntaxes.
      // The pasting application (e.g., TinyMCE, a textarea) will choose the best format.
      const htmlSyntax = `<img src="${attachmentData.url}" alt="${attachmentData.name}" />`;
      
      // Per user feedback, the plain text version should always be Markdown.
      // The Textile format is not needed, so we can remove the detection logic.
      const plainTextSyntax = `![](${attachmentData.url})`;

      console.log(`[Child Attachments] Preparing clipboard data. HTML: ${htmlSyntax}, PlainText: ${plainTextSyntax}`);

      try {
        const blobHtml = new Blob([htmlSyntax], { type: 'text/html' });
        const blobText = new Blob([plainTextSyntax], { type: 'text/plain' });
        const clipboardItem = new ClipboardItem({
          'text/html': blobHtml,
          'text/plain': blobText,
        });

        navigator.clipboard.write([clipboardItem]).then(() => {
          console.log('[Child Attachments] Successfully copied HTML and Plain Text to clipboard.');
          const originalText = link.textContent;
          link.textContent = 'Đã sao chép! Ctrl+V để dán vào trình soạn thảo.';
          link.style.fontWeight = 'bold';
          link.style.color = 'green';
          setTimeout(() => {
              link.textContent = originalText;
              link.style.fontWeight = 'normal';
              link.style.color = '';
          }, 3000);
        }).catch(err => {
          console.error('[Child Attachments] Failed to copy using ClipboardItem API: ', err);
          alert('Không thể sao chép liên kết.');
        });
      } catch (e) {
        console.error("[Child Attachments] ClipboardItem API not supported or failed, falling back to writeText.", e);
        // Fallback for older browsers: copy plain text only (which is always Markdown now).
        navigator.clipboard.writeText(plainTextSyntax);
        alert('Đã sao chép liên kết (chế độ văn bản).');
      }
    }
  });
}

document.addEventListener('DOMContentLoaded', function() {
  moveChildAttachmentsBlock();
  updateWysiwygAttachments();
  setupInsertAttachmentLinks();
}); 
