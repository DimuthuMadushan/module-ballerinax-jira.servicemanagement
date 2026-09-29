# Examples

The `ballerinax/jira.servicemanagement` connector provides practical examples illustrating usage in various scenarios.

1. **[Service request intake](https://github.com/ballerina-platform/module-ballerinax-jira.servicemanagement/tree/main/examples/service_request_intake)** - Find a request type by name, check its fields, raise a customer request and attach a supporting file to it.

2. **[Customer organization onboarding](https://github.com/ballerina-platform/module-ballerinax-jira.servicemanagement/tree/main/examples/customer_organization_onboarding)** - Create an organization for a new client company, give it access to a service desk, create its first customer and add them to the organization.

## Prerequisites

1. Create an Atlassian API token as described in the [Setup guide](https://central.ballerina.io/ballerinax/jira.servicemanagement/latest#setup-guide).

2. For each example, create a `Config.toml` file with the related configuration. Here's an example of how your Config.toml file should look:

```toml
serviceUrl = "https://your-domain.atlassian.net"
email = "<your-atlassian-account-email>"
apiToken = "<your-api-token>"
serviceDeskId = "<service-desk-id>"
```

Each example lists the additional values it needs in its own README.

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
