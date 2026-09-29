# Ballerina Jira Service Management connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-jira.servicemanagement/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-jira.servicemanagement/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-jira.servicemanagement.svg)](https://github.com/ballerina-platform/module-ballerinax-jira.servicemanagement/commits/main)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/jira.servicemanagement.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Fjira.servicemanagement)

## Overview

[Jira Service Management](https://www.atlassian.com/software/jira/service-management) is Atlassian's IT service management platform. Teams use it to run service desks where customers raise requests through a help-center portal, and agents triage those requests through queues, SLAs and approvals.

The Jira Service Management connector lets Ballerina applications work with the [Jira Service Management Cloud REST API](https://developer.atlassian.com/cloud/jira/service-desk/rest/intro/). It can raise and track customer requests, manage service desks, request types, queues, customers and organizations, and search the knowledge base. It supports the `servicedeskapi` REST API of Jira Service Management Cloud.

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

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`jira.servicemanagement` package](https://central.ballerina.io/ballerinax/jira.servicemanagement/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
