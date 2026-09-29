# Service request intake

This example raises a customer request on a Jira Service Management service desk and attaches a supporting file to it. It reads the file first, finds the request type by name, checks that the type collects a summary and a description and requires no other field, creates the request, uploads the file as a temporary attachment and then attaches it to the request with a customer-visible comment.

## Prerequisites

### 1. Set up credentials

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-jira.servicemanagement/blob/main/ballerina/README.md#setup-guide) to create an API token. The account must be able to raise requests on the service desk, and the service desk must allow attachments.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
serviceUrl = "https://your-domain.atlassian.net"
email = "<your-atlassian-account-email>"
apiToken = "<your-api-token>"
serviceDeskId = "<service-desk-id>"
requestTypeName = "<request-type-name, e.g. Get IT help>"
summary = "<request-summary>"
description = "<request-description>"
attachmentPath = "<path-to-a-file-to-attach>"
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```
