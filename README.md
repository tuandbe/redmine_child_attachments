# Redmine Child Attachments Plugin

This plugin enhances Redmine's issue view by displaying attachments from all of its child issues directly within the parent issue's page. This provides a consolidated, at-a-glance view of all relevant files across a task hierarchy, saving you from having to navigate to each sub-task individually.

## Features

- Displays a list of attachments from all child issues at the bottom of the parent issue page.
- For image attachments, provides a simple "Insert" button.
- The "Insert" button copies the appropriate image syntax (HTML for the Visual Editor, Markdown for text fields) to the clipboard.
- Allows for easy embedding of child issue images into the parent issue's description or comments.

## Installation

To install the plugin, please follow these steps:

1.  Navigate to your Redmine `plugins` directory from the Redmine root folder.
    ```bash
    cd plugins/
    ```

2.  Clone this repository into the `plugins` directory.
    ```bash
    git clone git@github.co:tuandbe/redmine_child_attachments.git
    ```
    
    Alternatively, if you are managing your Redmine instance with Git, you can add it as a submodule:
    ```bash
    # From your Redmine root directory
    git submodule add git@github.co:tuandbe/redmine_child_attachments.git plugins/redmine_child_attachments
    ```

3.  Restart your Redmine server.

    For example:
    ```bash
    touch tmp/restart.txt
    ```

After restarting, the plugin will be active and will display child attachments on issue pages.
