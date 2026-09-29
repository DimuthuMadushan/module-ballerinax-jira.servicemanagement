## Overview

[Jira Service Management](https://www.atlassian.com/software/jira/service-management) is Atlassian's IT service management platform. Teams use it to run service desks where customers raise requests through a help-center portal, and agents triage those requests through queues, SLAs and approvals.

The Jira Service Management connector lets Ballerina applications work with the [Jira Service Management Cloud REST API](https://developer.atlassian.com/cloud/jira/service-desk/rest/intro/). It can raise and track customer requests, manage service desks, request types, queues, customers and organizations, and search the knowledge base. It supports the `servicedeskapi` REST API of Jira Service Management Cloud.

### Key features

- Raise customer requests, validate them before submission, and follow their status, SLAs and approvals
- Comment on requests, attach files, manage participants and move requests through their workflow
- Manage customers and organizations, and control which of them can use each service desk
- Browse service desks, queues and the issues waiting in them, and configure request types and their fields
- Search the knowledge base and store custom properties on organizations and request types

## Setup guide

The connector authenticates to Jira Service Management Cloud with either an Atlassian API token (HTTP basic authentication) or an OAuth 2.0 access token. An API token is the quickest way to start.

### Step 1: Get access to a Jira Service Management site

You need a Jira Service Management Cloud site, such as `https://your-domain.atlassian.net`, and an account on it. If you do not have one, [start a free trial](https://www.atlassian.com/software/jira/service-management/free). Operations run with that account's permissions: most read and create operations need an agent or customer account on the service desk, while managing request types, customers and organizations needs a service desk administrator or agent.

### Step 2: Create an API token

1. Sign in to your Atlassian account and open [API tokens](https://id.atlassian.com/manage-profile/security/api-tokens).
2. Select **Create API token**, give it a label, choose an expiry date, and select **Create**.
3. Copy the token and store it securely. You cannot view it again after you close the dialog.

Use the email address of your Atlassian account as the username and the API token as the password.

### Step 3 (optional): Use OAuth 2.0 instead

To act on behalf of other users, create an OAuth 2.0 (3LO) app in the [Atlassian developer console](https://developer.atlassian.com/console/myapps/):

1. Select **Create** > **OAuth 2.0 integration**, and name the app.
2. Under **Permissions**, add the **Jira Service Management API** and select the scopes your application needs, such as `read:servicedesk-request` and `write:servicedesk-request`.
3. Under **Authorization**, set a callback URL, then follow [Atlassian's OAuth 2.0 (3LO) guide](https://developer.atlassian.com/cloud/jira/service-desk/oauth-2-3lo-apps/) to obtain an access token and a refresh token. Add the `offline_access` scope to receive a refresh token.
4. Find your site's cloud ID from `https://your-domain.atlassian.net/_edge/tenant_info`.

OAuth 2.0 requests go through the Atlassian API gateway, so the service URL is `https://api.atlassian.com/ex/jira/<cloud-id>` rather than your site URL.

## Quickstart

To use the Jira Service Management connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `jira.servicemanagement` module.

```ballerina
import ballerinax/jira.servicemanagement as jsm;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the obtained credentials and your site URL:

   ```toml
   serviceUrl = "https://your-domain.atlassian.net"
   email = "<your-atlassian-account-email>"
   apiToken = "<your-api-token>"
   ```

2. Create a `jsm:Client` with the credentials:

   ```ballerina
   configurable string serviceUrl = ?;
   configurable string email = ?;
   configurable string apiToken = ?;

   final jsm:Client jira = check new ({auth: {username: email, password: apiToken}}, serviceUrl);
   ```

   To use OAuth 2.0 instead, pass `auth: {token: "<access-token>"}` and set `serviceUrl` to `https://api.atlassian.com/ex/jira/<cloud-id>`.

### Step 3: Invoke the connector operation

Now, use the connector to call Jira Service Management. The following lists the service desks the account can see:

```ballerina
public function main() returns error? {
    jsm:PagedDTOServiceDeskDTO _ = check jira->getServiceDesks();
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The Jira Service Management connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-jira.servicemanagement/tree/main/examples/), covering the following use cases:

1. [Service request intake](https://github.com/ballerina-platform/module-ballerinax-jira.servicemanagement/tree/main/examples/service_request_intake) - Find a request type by name, check its fields, raise a customer request and attach a supporting file to it.

2. [Customer organization onboarding](https://github.com/ballerina-platform/module-ballerinax-jira.servicemanagement/tree/main/examples/customer_organization_onboarding) - Create an organization for a new client company, give it access to a service desk, create its first customer and add them to the organization.
