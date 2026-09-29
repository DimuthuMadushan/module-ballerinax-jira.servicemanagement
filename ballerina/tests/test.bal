// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/os;
import ballerina/test;
import ballerina/time;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? os:getEnv("JIRA_SM_SERVICE_URL") : "http://localhost:9090";
final string username = isLiveServer ? os:getEnv("JIRA_SM_EMAIL") : "fred@example-corp.io";
final string apiToken = isLiveServer ? os:getEnv("JIRA_SM_API_TOKEN") : "test_api_token";

final string serviceDeskId = isLiveServer ? os:getEnv("JIRA_SM_SERVICE_DESK_ID") : "10001";
final string requestTypeId = isLiveServer ? os:getEnv("JIRA_SM_REQUEST_TYPE_ID") : "11001";
final string issueTypeId = isLiveServer ? os:getEnv("JIRA_SM_ISSUE_TYPE_ID") : "10006";
final string issueKey = isLiveServer ? os:getEnv("JIRA_SM_ISSUE_KEY") : "SD-12";
final string accountId = isLiveServer ? os:getEnv("JIRA_SM_ACCOUNT_ID")
    : "qm:a713c8ea-1075-4e30-9d96-891a7d181739:5ad6d69abfa3980ce712caae";
final int queueId = isLiveServer ? check int:fromString(os:getEnv("JIRA_SM_QUEUE_ID")) : 10;

final Client jira = check new ({
    auth: {username, password: apiToken},
    // The mock is plain HTTP; HTTP/1.1 avoids the h2c upgrade on requests with a body.
    httpVersion: isLiveServer ? http:HTTP_2_0 : http:HTTP_1_1
}, serviceUrl);

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetInfo() returns error? {
    SoftwareInfoDTO info = check jira->getInfo();
    test:assertTrue(info.version !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetServiceDesks() returns error? {
    PagedDTOServiceDeskDTO page = check jira->getServiceDesks('limit = 10);
    test:assertTrue((page.values ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetServiceDeskById() returns error? {
    ServiceDeskDTO desk = check jira->getServiceDeskById(serviceDeskId);
    test:assertEquals(desk.id, serviceDeskId);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetQueues() returns error? {
    PagedDTOQueueDTO page = check jira->getQueues(serviceDeskId, includeCount = true);
    test:assertTrue((page.values ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetQueue() returns error? {
    QueueDTO queue = check jira->getQueue(serviceDeskId, queueId);
    test:assertEquals(queue.id, queueId.toString());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetIssuesInQueue() returns error? {
    PagedDTOIssueBean page = check jira->getIssuesInQueue(serviceDeskId, queueId);
    test:assertTrue(page.values !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetRequestTypes() returns error? {
    PagedDTORequestTypeDTO page = check jira->getRequestTypes(serviceDeskId);
    test:assertTrue((page.values ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetRequestTypeById() returns error? {
    RequestTypeDTO requestType = check jira->getRequestTypeById(serviceDeskId, requestTypeId);
    test:assertEquals(requestType.id, requestTypeId);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetRequestTypeFields() returns error? {
    int:Signed32 id = check int:fromString(requestTypeId).ensureType();
    CustomerRequestCreateMetaDTO meta = check jira->getRequestTypeFields(serviceDeskId, id);
    test:assertTrue((meta.requestTypeFields ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateRequestType() returns error? {
    RequestTypeDTO created = check jira->createRequestType(serviceDeskId, {
        issueTypeId,
        name: "Connector test request type",
        description: "Created by the Ballerina connector tests",
        helpText: "Used only by automated tests"
    });
    test:assertTrue(created.id !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteRequestType() returns error? {
    RequestTypeDTO created = check jira->createRequestType(serviceDeskId, {
        issueTypeId,
        name: "Connector test request type to delete",
        description: "Created and deleted by the Ballerina connector tests"
    });
    string? createdId = created.id;
    if createdId is () {
        return error("createRequestType returned no ID");
    }
    int:Signed32 id = check int:fromString(createdId).ensureType();
    error? result = jira->deleteRequestType(serviceDeskId, id);
    test:assertTrue(result is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetCustomerRequests() returns error? {
    PagedDTOCustomerRequestDTO page = check jira->getCustomerRequests(requestOwnership = ["PARTICIPATED_REQUESTS"]);
    test:assertTrue(page.values !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateCustomerRequest() returns error? {
    CustomerRequestDTO created = check jira->createCustomerRequest({
        serviceDeskId,
        requestTypeId,
        requestFieldValues: {
            "summary": "Laptop will not connect to the VPN",
            "description": "Created by the Ballerina connector tests"
        }
    });
    test:assertTrue(created.issueKey !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetCustomerRequestByIdOrKey() returns error? {
    CustomerRequestDTO request = check jira->getCustomerRequestByIdOrKey(issueKey);
    test:assertEquals(request.issueKey, issueKey);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetRequestComments() returns error? {
    PagedDTOCommentDTO page = check jira->getRequestComments(issueKey);
    test:assertTrue(page.values !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateRequestComment() returns error? {
    CommentDTO comment = check jira->createRequestComment(issueKey, {
        body: "Added by the Ballerina connector tests",
        'public: true
    });
    test:assertEquals(comment.body, "Added by the Ballerina connector tests");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetCustomerTransitions() returns error? {
    PagedDTOCustomerTransitionDTO page = check jira->getCustomerTransitions(issueKey);
    test:assertTrue(page.values !is ());
}

// Live, the transition ID has to be one the request's current status offers.
@test:Config {groups: ["mock_tests"]}
isolated function testPerformCustomerTransition() returns error? {
    error? result = jira->performCustomerTransition(issueKey, {
        id: "1",
        additionalComment: {body: "Closing this request from the connector tests"}
    });
    test:assertTrue(result is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetApprovals() returns error? {
    PagedDTOApprovalDTO page = check jira->getApprovals(issueKey);
    test:assertTrue(page.values !is ());
}

// Live, this needs a pending approval that the calling user is an approver on.
@test:Config {groups: ["mock_tests"]}
isolated function testAnswerApproval() returns error? {
    ApprovalDTO approval = check jira->answerApproval(issueKey, 1, {decision: "approve"});
    test:assertEquals(approval.finalDecision, "approved");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetSlaInformation() returns error? {
    PagedDTOSlaInformationDTO page = check jira->getSlaInformation(issueKey);
    test:assertTrue(page.values !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetRequestParticipants() returns error? {
    PagedDTOUserDTO page = check jira->getRequestParticipants(issueKey);
    test:assertTrue(page.values !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testAddRequestParticipants() returns error? {
    PagedDTOUserDTO page = check jira->addRequestParticipants(issueKey, {accountIds: [accountId]});
    UserDTO[] participants = page.values ?: [];
    test:assertTrue(participants.some(p => p.accountId == accountId));
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetOrganizations() returns error? {
    PagedDTOOrganizationDTO page = check jira->getOrganizations();
    test:assertTrue(page.values !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateOrganization() returns error? {
    OrganizationDTO organization = check jira->createOrganization({name: "Connector Test Organization"});
    test:assertEquals(organization.name, "Connector Test Organization");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetOrganization() returns error? {
    OrganizationDTO created = check jira->createOrganization({name: "Connector Test Organization To Read"});
    int:Signed32 id = check organizationId(created);
    OrganizationDTO organization = check jira->getOrganization(id);
    test:assertEquals(organization.id, created.id);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testAddUsersToOrganization() returns error? {
    OrganizationDTO created = check jira->createOrganization({name: "Connector Test Organization With Users"});
    int:Signed32 id = check organizationId(created);
    error? result = jira->addUsersToOrganization(id, {accountIds: [accountId]});
    test:assertTrue(result is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteOrganization() returns error? {
    OrganizationDTO created = check jira->createOrganization({name: "Connector Test Organization To Delete"});
    int:Signed32 id = check organizationId(created);
    error? result = jira->deleteOrganization(id);
    test:assertTrue(result is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateCustomer() returns error? {
    // Live runs need a fresh email each time; Jira rejects one that already has an account.
    string email = isLiveServer ? string `connector-test-customer-${time:utcNow()[0]}@example-corp.io`
        : "connector-test-customer@example-corp.io";
    UserDTO customer = check jira->createCustomer({
        displayName: "Connector Test Customer",
        email
    });
    test:assertTrue(customer.accountId !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testAttachTemporaryFile() returns error? {
    TemporaryAttachments result = check jira->attachTemporaryFile(serviceDeskId, {
        file: {fileContent: "VPN client log".toBytes(), fileName: "vpn.log"}
    });
    test:assertTrue((result.temporaryAttachments ?: []).length() > 0);
}

isolated function organizationId(OrganizationDTO organization) returns int:Signed32|error {
    string? id = organization.id;
    if id is () {
        return error("createOrganization returned no ID");
    }
    return int:fromString(id).ensureType();
}
