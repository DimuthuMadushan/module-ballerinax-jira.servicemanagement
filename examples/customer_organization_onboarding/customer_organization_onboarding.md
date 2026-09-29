# Customer organization onboarding

This example onboards a new client company to a Jira Service Management service desk. It creates an organization for the company, gives the organization access to the service desk, creates the company's first customer account, adds that customer to the organization, and then lists every member of the organization to confirm.

## Prerequisites

### 1. Set up credentials

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-jira.servicemanagement/blob/main/ballerina/README.md#setup-guide) to create an API token. The account needs the Jira Administrator global permission, which `createCustomer` requires. It must also be a service desk administrator or agent, and the site must let agents create customers and organizations.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
serviceUrl = "https://your-domain.atlassian.net"
email = "<your-atlassian-account-email>"
apiToken = "<your-api-token>"
serviceDeskId = "<service-desk-id>"
organizationName = "<organization-name>"
customerEmail = "<customer-email>"
customerDisplayName = "<customer-display-name>"
```

Creating a customer does not by itself invite them. Sending an invitation needs the separate service desk invitation endpoint (`inviteCustomer`), and whether the customer receives it depends on the site's customer notification settings. If a customer with `customerEmail` already exists, the example reuses that account instead of creating a new one.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
