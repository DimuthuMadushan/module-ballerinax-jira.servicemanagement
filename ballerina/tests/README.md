# Running Tests

The test suite covers 30 of the connector's operations across service desks, queues, request types, customer requests (comments, participants, approvals, SLAs and transitions), organizations, customers and temporary attachments. Each delete test creates the entity it deletes.

## Prerequisites

To run the tests against a live Jira Service Management site you need an Atlassian account email and API token. Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-jira.servicemanagement/blob/main/ballerina/README.md#setup-guide) to obtain them. The account must be an agent or administrator on the service desk the tests use.

## Test environments

There are two test environments. The default is a mock server for the Jira Service Management API. The other is a live Jira Service Management Cloud site.

 Test Groups | Environment
-------------|------------------------------------------------
 mock_tests  | Mock server for the Jira Service Management API (default)
 live_tests  | Jira Service Management Cloud

## Running tests against the mock server

No configuration is needed. When `IS_LIVE_SERVER` is not set to `true`, the tests run against the mock server on port `9090`.

```bash
./gradlew clean test
```

## Running tests against a live site

Set the following environment variables, then run the tests.

| Variable | Description |
|---|---|
| `IS_LIVE_SERVER` | Set to `true` to target the live site instead of the mock server |
| `JIRA_SM_SERVICE_URL` | Your site URL, for example `https://your-domain.atlassian.net` |
| `JIRA_SM_EMAIL` | Email address of the Atlassian account |
| `JIRA_SM_API_TOKEN` | API token of the Atlassian account |
| `JIRA_SM_SERVICE_DESK_ID` | ID of the service desk to test against |
| `JIRA_SM_REQUEST_TYPE_ID` | ID of a request type in that service desk that has summary and description fields |
| `JIRA_SM_ISSUE_TYPE_ID` | ID of an issue type used when creating request types |
| `JIRA_SM_ISSUE_KEY` | Key of an existing customer request, for example `SD-12` |
| `JIRA_SM_ACCOUNT_ID` | Account ID of a user to add as a participant and organization member |
| `JIRA_SM_QUEUE_ID` | ID of a queue in the service desk |

```bash
./gradlew clean test -Pgroups=live_tests
```

`testPerformCustomerTransition` and `testAnswerApproval` run only against the mock server, because live they need a request in a state that offers that transition and a pending approval the account can answer.
