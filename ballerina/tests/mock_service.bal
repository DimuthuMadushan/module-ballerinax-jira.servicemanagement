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

listener http:Listener ep0 = new (9090);

service / on ep0 {
    # Delete organization
    #
    # + organizationId - The ID of the organization
    # + return - returns can be any of following types 
    # http:NoContent (Returned if the organization was deleted)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the organization does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function delete rest/servicedeskapi/organization/[int:Signed32 organizationId]() returns http:NoContent|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return http:NO_CONTENT;
    }

    # Delete request type
    #
    # + serviceDeskId - The ID or [project identifier](#project-identifiers) of the service desk
    # + requestTypeId - The ID of the request type
    # + return - returns can be any of following types 
    # http:NoContent (Returned if the request type is deleted)
    # http:BadRequest (Returned if the request type ID is not valid.)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have the necessary permission to complete this request.)
    # http:NotFound (Returned if the service desk or request type do not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function delete rest/servicedeskapi/servicedesk/[string serviceDeskId]/requesttype/[int:Signed32 requestTypeId]() returns http:NoContent|ErrorResponseBadRequest|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return http:NO_CONTENT;
    }

    # Get Jira Service Management instance info
    #
    # + return - returns can be any of following types 
    # http:Ok (Returns the runtime information for the Jira Service Management instance)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/info() returns SoftwareInfoDTO|ErrorResponseInternalServerError {
        return {version: "10.3.0", platformVersion: "1001.0.0", buildChangeSet: "a1b2c3d4e5f6", isLicensedForUse: true, buildDate: date("2026-09-01T10:00:00.000+0000"), links: {self: BASE + "/info"}};
    }

    # Get organizations
    #
    # + 'start - The starting index of the returned objects. Base index: 0. See the [Pagination](#pagination) section for more details
    # + 'limit - The maximum number of organizations to return per page. Default: 50. See the [Pagination](#pagination) section for more details
    # + accountId - The account ID of the user, which uniquely identifies the user across all Atlassian products. For example, *5b10ac8d82e05b22cc7d4ef5*
    # + return - returns can be any of following types 
    # http:Ok (Returns paginated list of organizations)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have the necessary permission.)
    # http:NotFound (Returned if the user is not found.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/organization(int:Signed32? 'start, int:Signed32? 'limit, string? accountId) returns PagedDTOOrganizationDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return {size: 2, 'start: 0, 'limit: 50, isLastPage: true, values: [organization("1", "Charlie Cakes Franchises"), organization("2", "Atlas Logistics")], links: pageLinks("/organization")};
    }

    # Get organization
    #
    # + organizationId - The ID of the organization
    # + return - returns can be any of following types 
    # http:Ok (Returns the requested organization)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the organization does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/organization/[int:Signed32 organizationId]() returns OrganizationDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return organization(organizationId.toString(), "Charlie Cakes Franchises");
    }

    # Get customer requests
    #
    # + searchTerm - Filters customer requests where the request summary matches the `searchTerm`. [Wildcards](https://confluence.atlassian.com/display/JIRACORECLOUD/Search+syntax+for+text+fields) can be used in the `searchTerm` parameter
    # + requestOwnership - Filters customer requests using the following values:
    # *  `OWNED_REQUESTS` returns customer requests where the user is the creator.
    # *  `PARTICIPATED_REQUESTS` returns customer requests where the user is a participant.
    # *  `ORGANIZATION` returns customer requests for an organization of which the user is a member when used in conjunction with `organizationId`.
    # *  `ALL_ORGANIZATIONS` returns customer requests that belong to all organizations of which the user is a member.
    # *  `APPROVER` returns customer requests where the user is an approver. Can be used in conjunction with `approvalStatus` to filter pending or complete approvals.
    # *  `ALL_REQUESTS` returns all customer requests. **Deprecated and will be removed, as the returned requests may change if more values are added in the future. Instead, explicitly list the desired filtering strategies.**
    # Multiple values of the query parameter are supported. For example, `requestOwnership=OWNED_REQUESTS&requestOwnership=PARTICIPATED_REQUESTS` will only return customer requests where the user is the creator or a participant. If not specified, filtering defaults to `OWNED_REQUESTS`, `PARTICIPATED_REQUESTS`, and `ALL_ORGANIZATIONS`
    # + requestStatus - Filters customer requests where the request is closed, open, or either of the two where:
    # *  `CLOSED_REQUESTS` returns customer requests that are closed.
    # *  `OPEN_REQUESTS` returns customer requests that are open.
    # *  `ALL_REQUESTS` returns all customer requests
    # + approvalStatus - Filters results to customer requests based on their approval status:
    # *  `MY_PENDING_APPROVAL` returns customer requests pending the user's approval.
    # *  `MY_HISTORY_APPROVAL` returns customer requests where the user was an approver.
    # **Note**: Valid only when used with requestOwnership=APPROVER
    # + organizationId - Filters customer requests that belong to a specific organization (note that the user must be a member of that organization). **Note**: Valid only when used with requestOwnership=ORGANIZATION
    # + serviceDeskId - Filters customer requests by service desk
    # + requestTypeId - Filters customer requests by request type. Note that the `serviceDeskId` must be specified for the service desk in which the request type belongs
    # + expand - A multi-value parameter indicating which properties of the customer request to expand, where:
    # *  `serviceDesk` returns additional details for each service desk.
    # *  `requestType` returns additional details for each request type.
    # *  `participant` returns the participant details, if any, for each customer request.
    # *  `sla` returns the SLA information on each customer request.
    # *  `status` returns the status transitions, in chronological order, for each customer request.
    # *  `attachment` returns the attachments for the customer request.
    # *  `action` returns the actions that the user can or cannot perform on this customer request.
    # *  `comment` returns the comments, if any, for each customer request.
    # *  `comment.attachment` returns the attachment details, if any, for each comment.
    # *  `comment.renderedBody` (Experimental) returns the rendered body in HTML format (in addition to the raw body) for each comment
    # + 'start - The starting index of the returned objects. Base index: 0. See the [Pagination](#pagination) section for more details
    # + 'limit - The maximum number of items to return per page. Default: 50. See the [Pagination](#pagination) section for more details
    # + return - returns can be any of following types 
    # http:Ok (Returns the customer requests, on the specified page of the results)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:NotFound (Returned if the user does not have permission to access the service desk, the service desk does not exist, or the service desk does not support the request type.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/request(string? searchTerm, string[]? requestOwnership, string? requestStatus, string? approvalStatus, int:Signed32? organizationId, int:Signed32? serviceDeskId, int:Signed32? requestTypeId, string[]? expand, int:Signed32? 'start, int:Signed32? 'limit) returns PagedDTOCustomerRequestDTO|ErrorResponseUnauthorized|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return {size: 1, 'start: 0, 'limit: 50, isLastPage: true, values: [customerRequest("10010", "SD-12")], links: pageLinks("/request")};
    }

    # Get customer request by id or key
    #
    # + issueIdOrKey - The ID or Key of the customer request to be returned
    # + expand - A multi-value parameter indicating which properties of the customer request to expand, where:
    # *  `serviceDesk` returns additional service desk details.
    # *  `requestType` returns additional customer request type details.
    # *  `participant` returns the participant details.
    # *  `sla` returns the SLA information.
    # *  `status` returns the status transitions, in chronological order.
    # *  `attachment` returns the attachments.
    # *  `action` returns the actions that the user can or cannot perform.
    # *  `comment` returns the comments.
    # *  `comment.attachment` returns the attachment details for each comment.
    # *  `comment.renderedBody` (Experimental) return the rendered body in HTML format (in addition to the raw body) for each comment
    # + return - returns can be any of following types 
    # http:Ok (Returns the customer request)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the customer request does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/request/[string issueIdOrKey](string[]? expand) returns CustomerRequestDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return customerRequest("10010", issueIdOrKey);
    }

    # Get approvals
    #
    # + 'start - The starting index of the returned objects. Base index: 0. See the [Pagination](#pagination) section for more details
    # + 'limit - The maximum number of approvals to return per page. Default: 50. See the [Pagination](#pagination) section for more details
    # + issueIdOrKey - The ID or key of the customer request to be queried for its approvals
    # + return - returns can be any of following types 
    # http:Ok (Returns the customer request's approvals)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the customer request does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/request/[string issueIdOrKey]/approval(int:Signed32? 'start, int:Signed32? 'limit) returns PagedDTOApprovalDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return {size: 1, 'start: 0, 'limit: 50, isLastPage: true, values: [approval("1", "pending")], links: pageLinks(string `/request/${issueIdOrKey}/approval`)};
    }

    # Get request comments
    #
    # + issueIdOrKey - The ID or key of the customer request whose comments will be retrieved
    # + 'public - Specifies whether to return public comments or not. Default: true
    # + internal - Specifies whether to return internal comments or not. Default: true
    # + expand - A multi-value parameter indicating which properties of the comment to expand:
    # *  `attachment` returns the attachment details, if any, for each comment. (If you want to get all attachments for a request, use [servicedeskapi/request/\{issueIdOrKey\}/attachment](#api-request-issueIdOrKey-attachment-get).)
    # *  `renderedBody` (Experimental) returns the rendered body in HTML format (in addition to the raw body) for each comment
    # + 'start - The starting index of the returned comments. Base index: 0. See the [Pagination](#pagination) section for more details
    # + 'limit - The maximum number of comments to return per page. Default: 50. See the [Pagination](#pagination) section for more details
    # + return - returns can be any of following types 
    # http:Ok (Returns the comments, on the specified page of the results)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:NotFound (Returned if the customer request does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/request/[string issueIdOrKey]/comment(boolean? 'public, boolean? internal, string[]? expand, int:Signed32? 'start, int:Signed32? 'limit) returns PagedDTOCommentDTO|ErrorResponseUnauthorized|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return {size: 1, 'start: 0, 'limit: 50, isLastPage: true, values: [comment("1000", "Thanks, we are looking into it.")], links: pageLinks(string `/request/${issueIdOrKey}/comment`)};
    }

    # Get request participants
    #
    # + issueIdOrKey - The ID or key of the customer request to be queried for its participants
    # + 'start - The starting index of the returned objects. Base index: 0. See the [Pagination](#pagination) section for more details
    # + 'limit - The maximum number of request types to return per page. Default: 50. See the [Pagination](#pagination) section for more details
    # + return - returns can be any of following types 
    # http:Ok (Returns the customer request's participants, on the specified page of the results)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the customer request does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/request/[string issueIdOrKey]/participant(int:Signed32? 'start, int:Signed32? 'limit) returns PagedDTOUserDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return {size: 1, 'start: 0, 'limit: 50, isLastPage: true, values: [user("qm:a713c8ea-1075-4e30-9d96-891a7d181739:5ad6d69abfa3980ce712caae", "Fred F. User")], links: pageLinks(string `/request/${issueIdOrKey}/participant`)};
    }

    # Get sla information
    #
    # + issueIdOrKey - The ID or key of the customer request whose SLAs will be retrieved
    # + 'start - The starting index of the returned objects. Base index: 0. See the [Pagination](#pagination) section for more details
    # + 'limit - The maximum number of request types to return per page. Default: 50. See the [Pagination](#pagination) section for more details
    # + return - returns can be any of following types 
    # http:Ok (Returns the SLA records on the customer request, on the specified page of the results)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to view this customer request. This includes the case where the user is not an agent on the Service Desk, or where the user lacks Browse Projects permission on the issue (for example, due to an issue security scheme or a custom permission scheme).)
    # http:NotFound (Returned if the customer request does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/request/[string issueIdOrKey]/sla(int:Signed32? 'start, int:Signed32? 'limit) returns PagedDTOSlaInformationDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return {size: 1, 'start: 0, 'limit: 50, isLastPage: true, values: [{id: "1", name: "Time to first response", slaDisplayFormat: "NEW_SLA_FORMAT", ongoingCycle: {breached: false, paused: false, withinCalendarHours: true, startTime: date("2026-09-28T09:00:00.000+0000"), breachTime: date("2026-09-28T13:00:00.000+0000"), goalDuration: {millis: 14400000, friendly: "4h"}, elapsedTime: {millis: 3600000, friendly: "1h"}, remainingTime: {millis: 10800000, friendly: "3h"}}, links: {self: BASE + string `/request/${issueIdOrKey}/sla/1`}}], links: pageLinks(string `/request/${issueIdOrKey}/sla`)};
    }

    # Get customer transitions
    #
    # + issueIdOrKey - The ID or key of the customer request whose transitions will be retrieved
    # + 'start - The starting index of the returned objects. Base index: 0. See the [Pagination](#pagination) section for more details
    # + 'limit - The maximum number of items to return per page. Default: 50. See the [Pagination](#pagination) section for more details
    # + return - returns can be any of following types 
    # http:Ok (Returns the transitions available to the user on the customer request)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the customer request does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/request/[string issueIdOrKey]/transition(int:Signed32? 'start, int:Signed32? 'limit) returns PagedDTOCustomerTransitionDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return {size: 2, 'start: 0, 'limit: 50, isLastPage: true, values: [{id: "1", name: "Cancel request"}, {id: "2", name: "Resolve issue"}], links: pageLinks(string `/request/${issueIdOrKey}/transition`)};
    }

    # Get service desks
    #
    # + 'start - The starting index of the returned objects. Base index: 0. See the [Pagination](#pagination) section for more details
    # + 'limit - The maximum number of items to return per page. Default: 50. See the [Pagination](#pagination) section for more details
    # + return - returns can be any of following types 
    # http:Ok (Returns the service desks, on the specified page of the results)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/servicedesk(int:Signed32? 'start, int:Signed32? 'limit) returns PagedDTOServiceDeskDTO|ErrorResponseUnauthorized|ErrorResponseInternalServerError {
        return {size: 1, 'start: 0, 'limit: 50, isLastPage: true, values: [serviceDesk("10001")], links: pageLinks("/servicedesk")};
    }

    # Get service desk by id
    #
    # + serviceDeskId - The ID of the service desk to return. This can alternatively be a [project identifier.](#project-identifiers)
    # + return - returns can be any of following types 
    # http:Ok (Returns the requested service desk)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if service desk does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/servicedesk/[string serviceDeskId]() returns ServiceDeskDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return serviceDesk(serviceDeskId);
    }

    # Get queues
    #
    # + serviceDeskId - ID of the service desk whose queues will be returned. This can alternatively be a [project identifier.](#project-identifiers)
    # + includeCount - Specifies whether to include each queue's customer request (issue) count in the response
    # + 'start - The starting index of the returned objects. Base index: 0. See the [Pagination](#pagination) section for more details
    # + 'limit - The maximum number of items to return per page. Default: 50. See the [Pagination](#pagination) section for more details
    # + return - returns can be any of following types 
    # http:Ok (Returns the queues of the service desk, on the specified page of the results)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the service desk does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/servicedesk/[string serviceDeskId]/queue(int:Signed32? 'start, int:Signed32? 'limit, boolean includeCount = false) returns PagedDTOQueueDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return {size: 1, 'start: 0, 'limit: 50, isLastPage: true, values: [queue(10)], links: pageLinks(string `/servicedesk/${serviceDeskId}/queue`)};
    }

    # Get a service desk queue
    #
    # + serviceDeskId - ID of the service desk whose queues will be returned. This can alternatively be a [project identifier.](#project-identifiers)
    # + queueId - ID of the required queue
    # + includeCount - Specifies whether to include each queue's customer request (issue) count in the response
    # + return - returns can be any of following types 
    # http:Ok (Returns the specific queue of the service desk)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the service desk does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/servicedesk/[string serviceDeskId]/queue/[int queueId](boolean includeCount = false) returns QueueDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return queue(queueId);
    }

    # Get issues in queue
    #
    # + serviceDeskId - The ID of the service desk containing the queue to be queried. This can alternatively be a [project identifier.](#project-identifiers)
    # + queueId - The ID of the queue whose customer requests will be returned
    # + 'start - The starting index of the returned objects. Base index: 0. See the [Pagination](#pagination) section for more details
    # + 'limit - The maximum number of items to return per page. Default: 50. See the [Pagination](#pagination) section for more details
    # + return - returns can be any of following types 
    # http:Ok (Returns the customer requests belonging to the queue, on the specified page of the results)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the service desk or the queue do not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/servicedesk/[string serviceDeskId]/queue/[int queueId]/issue(int:Signed32? 'start, int:Signed32? 'limit) returns PagedDTOIssueBean|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return {size: 1, 'start: 0, 'limit: 50, isLastPage: true, values: [{id: "10010", 'key: "SD-12", self: BASE_JIRA + "/issue/10010", fields: {"summary": "Request JSD help via REST", "status": {"name": "Waiting for support"}}}], links: pageLinks(string `/servicedesk/${serviceDeskId}/queue/${queueId}/issue`)};
    }

    # Get request types
    #
    # + serviceDeskId - The ID of the service desk whose customer request types are to be returned. This can alternatively be a [project identifier.](#project-identifiers)
    # + groupId - Filters results to those in a customer request type group
    # + expand - Comma-separated list of entities to expand in the response
    # + searchQuery - The string to be used to filter the results
    # + 'start - The starting index of the returned objects. Base index: 0. See the [Pagination](#pagination) section for more details
    # + 'limit - The maximum number of items to return per page. Default: 50. See the [Pagination](#pagination) section for more details
    # + includeHiddenRequestTypesInSearch - Whether to include hidden request types when searching with `searchQuery`
    # + restrictionStatus - Request type restriction status (`open` or `restricted`) used to filter the results
    # + return - returns can be any of following types 
    # http:Ok (Returns the requested customer request types, on the specified page of the results)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the service desk does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/servicedesk/[string serviceDeskId]/requesttype(int:Signed32? groupId, string[]? expand, string? searchQuery, int:Signed32? 'start, int:Signed32? 'limit, string? restrictionStatus, boolean includeHiddenRequestTypesInSearch = false) returns PagedDTORequestTypeDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return {size: 1, 'start: 0, 'limit: 50, isLastPage: true, values: [requestType("11001", serviceDeskId)], links: pageLinks(string `/servicedesk/${serviceDeskId}/requesttype`)};
    }

    resource function get rest/servicedeskapi/servicedesk/[string serviceDeskId]/requesttype/[int:Signed32 requestTypeId]/'field(string[]? expand) returns CustomerRequestCreateMetaDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return {canRaiseOnBehalfOf: true, canAddRequestParticipants: true, requestTypeFields: [{fieldId: "summary", name: "What do you need?", description: "Summarize your request", required: true, visible: true, jiraSchema: {'type: "string", system: "summary"}, validValues: [], defaultValues: []}, {fieldId: "description", name: "Why do you need this?", description: "Tell us more about your request", required: false, visible: true, jiraSchema: {'type: "string", system: "description"}, validValues: [], defaultValues: []}]};
    }

    # Get request type by id
    #
    # + serviceDeskId - The ID of the service desk whose customer request type is to be returned. This can alternatively be a [project identifier.](#project-identifiers)
    # + requestTypeId - The ID of the customer request type to be returned
    # + expand - Comma-separated list of entities to expand in the response
    # + return - returns can be any of following types 
    # http:Ok (Returns the customer request type item)
    # http:Unauthorized (Returned if the user credentials are invalid.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the service desk or customer request type do not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function get rest/servicedeskapi/servicedesk/[string serviceDeskId]/requesttype/[string requestTypeId](string[]? expand) returns RequestTypeDTO|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return requestType(requestTypeId, serviceDeskId);
    }

    # Create customer
    #
    # + strictConflictStatusCode - Optional boolean flag to return 409 Conflict status code for duplicate customer creation request
    # + payload - Email address and display name of the customer to create 
    # + return - returns can be any of following types 
    # http:Created (Returns the customer details)
    # http:BadRequest (Returned if the request is invalid, either because the email address is incorrectly formed or already exists in the database if `strictConflictStatusCode=false` or if `strictConflictStatusCode` parameter is not provided)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:Conflict (Returned if the request is invalid because the email address already exists in the database and `strictConflictStatusCode=true`)
    # http:InternalServerError (Internal Server Error.)
    resource function post rest/servicedeskapi/customer(boolean? strictConflictStatusCode, @http:Payload CustomerCreateDTO payload) returns UserDTO|ErrorResponseBadRequest|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseConflict|ErrorResponseInternalServerError {
        return user("qm:a713c8ea-1075-4e30-9d96-891a7d181739:7cd6f7ee-7a8f-4e4c-8cf3-b0d5a7c3b1a2", payload.displayName ?: "New Customer", payload.email);
    }

    # Create organization
    #
    # + payload - Name of the organization to create 
    # + return - returns can be any of following types 
    # http:Created (Returns the created organization or the existing organization if name already exists)
    # http:BadRequest (Returned if the HTTP request is invalid.)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:InternalServerError (Internal Server Error.)
    resource function post rest/servicedeskapi/organization(@http:Payload OrganizationCreateDTO payload) returns OrganizationDTO|ErrorResponseBadRequest|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseInternalServerError {
        return organization("3", payload.name);
    }

    # Add users to organization
    #
    # + organizationId - The ID of the organization
    # + payload - Account IDs of the users to add to the organization 
    # + return - returns can be any of following types 
    # http:NoContent (Returned if all the users were valid and added to the organization, no response payload is provided)
    # http:BadRequest (Returned if one or more usernames are unknown.)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the organization does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function post rest/servicedeskapi/organization/[int:Signed32 organizationId]/user(@http:Payload UsersOrganizationUpdateDTO payload) returns http:NoContent|ErrorResponseBadRequest|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return http:NO_CONTENT;
    }

    # Create customer request
    #
    # + payload - Service desk, request type and field values of the customer request to create 
    # + return - returns can be any of following types 
    # http:Created (Returned if the customer request was created)
    # http:BadRequest (Returned if the HTTP request call is invalid.)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:UnprocessableEntity (Returned if one or more form answers fail validation rules configured by Jira admins.)
    # http:InternalServerError (Internal Server Error.)
    resource function post rest/servicedeskapi/request(@http:Payload RequestCreateDTO payload) returns CustomerRequestDTO|ErrorResponseBadRequest|ErrorResponseUnauthorized|ErrorResponseForbidden|FormValidationErrorResponseDTOUnprocessableEntity|ErrorResponseInternalServerError {
        CustomerRequestDTO created = customerRequest("10020", "SD-13");
        created.serviceDeskId = payload.serviceDeskId ?: "10001";
        created.requestTypeId = payload.requestTypeId ?: "11001";
        return created;
    }

    # Answer approval
    #
    # + issueIdOrKey - The ID or key of the customer request to be updated
    # + approvalId - The ID of the approval to be updated
    # + payload - Approve or decline decision to record on the approval 
    # + return - returns can be any of following types 
    # http:Ok (Returns the updated approval)
    # http:BadRequest (Returned if the request is not valid.)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the customer request or the approval do not exist.)
    # http:Conflict (Returned if the customer has already submitted a decision or the approval has already been completed.)
    # http:InternalServerError (Internal Server Error.)
    resource function post rest/servicedeskapi/request/[string issueIdOrKey]/approval/[int:Signed32 approvalId](@http:Payload ApprovalDecisionRequestDTO payload) returns ApprovalDTOOk|ErrorResponseBadRequest|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseConflict|ErrorResponseInternalServerError {
        ApprovalDTO answered = approval(approvalId.toString(), payload.decision == "decline" ? "declined" : "approved");
        answered.canAnswerApproval = false;
        answered.completedDate = date("2026-09-28T11:30:00.000+0000");
        return <ApprovalDTOOk>{body: answered};
    }

    # Create request comment
    #
    # + issueIdOrKey - The ID or key of the customer request to which the comment will be added
    # + payload - Body and visibility of the comment to add to the request 
    # + return - returns can be any of following types 
    # http:Created (Returns the comment)
    # http:BadRequest (Returned if the HTTP request is invalid, e.g. missing the required `public`.)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the customer request does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function post rest/servicedeskapi/request/[string issueIdOrKey]/comment(@http:Payload CommentCreateDTO payload) returns CommentDTO|ErrorResponseBadRequest|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        CommentDTO created = comment("1001", payload.body ?: "");
        created.'public = payload.'public ?: true;
        return created;
    }

    # Add request participants
    #
    # + issueIdOrKey - The ID or key of the customer request to have participants added
    # + payload - Account IDs of the users to add as request participants 
    # + return - returns can be any of following types 
    # http:Ok (Returns the participants added to the customer request)
    # http:BadRequest (Returned if any user to be added as a participant does not exist.)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the customer request does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function post rest/servicedeskapi/request/[string issueIdOrKey]/participant(@http:Payload RequestParticipantUpdateDTO payload) returns PagedDTOUserDTOOk|ErrorResponseBadRequest|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        UserDTO[] participants = from string accountId in payload.accountIds ?: [] select user(accountId, "Participant " + accountId.substring(0, 4));
        return <PagedDTOUserDTOOk>{body: {size: <int:Signed32>participants.length(), 'start: 0, 'limit: 50, isLastPage: true, values: participants, links: pageLinks(string `/request/${issueIdOrKey}/participant`)}};
    }

    # Perform customer transition
    #
    # + issueIdOrKey - ID or key of the issue to transition
    # + payload - ID of the transition to perform and an optional comment 
    # + return - returns can be any of following types 
    # http:NoContent (Returned if the request is transitioned)
    # http:BadRequest (Returned if the transition ID is invalid or the comment is too long.)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the request does not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function post rest/servicedeskapi/request/[string issueIdOrKey]/transition(@http:Payload CustomerTransitionExecutionDTO payload) returns http:NoContent|ErrorResponseBadRequest|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        return http:NO_CONTENT;
    }

    # Attach temporary file
    #
    # + serviceDeskId - The ID of the Service Desk to which the file will be attached. This can alternatively be a [project identifier.](#project-identifiers)
    # + X\-Atlassian\-Token - XSRF protection bypass that Jira requires on multipart requests. Must be `no-check`
    # + request - Files to upload as temporary attachments, as multipart form data
    # + return - returns can be any of following types 
    # http:Created (Returns if the file(s) were attached)
    # http:BadRequest (Returned if the attachments are not valid, or exceed the maximum configured attachment size.)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the service desk does not exist.)
    # http:PayloadTooLarge (Returned if more than 60 files are requested to be uploaded.)
    # http:InternalServerError (Internal Server Error.)
    resource function post rest/servicedeskapi/servicedesk/[string serviceDeskId]/attachTemporaryFile(http:Request request, @http:Header string? X\-Atlassian\-Token = "no-check") returns TemporaryAttachments|ErrorResponseBadRequest|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponsePayloadTooLarge|ErrorResponseInternalServerError {
        return {temporaryAttachments: [{temporaryAttachmentId: "temp8186986881700442965", fileName: "screenshot.png"}]};
    }

    # Create request type
    #
    # + serviceDeskId - The ID of the service desk where the customer request type is to be created. This can alternatively be a [project identifier.](#project-identifiers)
    # + payload - Issue type, name and help text of the request type to create 
    # + return - returns can be any of following types 
    # http:Ok (Returns the customer request type created)
    # http:BadRequest (Returned if the customer request type name is empty.)
    # http:Unauthorized (Returned if the user is not logged in.)
    # http:Forbidden (Returned if the user does not have permission to complete this request.)
    # http:NotFound (Returned if the service desk or issue type do not exist.)
    # http:InternalServerError (Internal Server Error.)
    resource function post rest/servicedeskapi/servicedesk/[string serviceDeskId]/requesttype(@http:Payload RequestTypeCreateDTO payload) returns RequestTypeDTOOk|ErrorResponseBadRequest|ErrorResponseUnauthorized|ErrorResponseForbidden|ErrorResponseNotFound|ErrorResponseInternalServerError {
        RequestTypeDTO created = requestType("11002", serviceDeskId);
        created.name = payload.name ?: "New request type";
        created.description = payload.description;
        created.helpText = payload.helpText;
        created.issueTypeId = payload.issueTypeId;
        return <RequestTypeDTOOk>{body: created};
    }
}

const BASE = "https://your-domain.atlassian.net/rest/servicedeskapi";
const BASE_JIRA = "https://your-domain.atlassian.net/rest/api/2";

isolated function date(string iso) returns DateDTO => {iso8601: iso, jira: iso, friendly: "Today 9:00 AM", epochMillis: 1790586000000};

isolated function pageLinks(string path) returns PagedLinkDTO => {base: "https://your-domain.atlassian.net/rest/servicedeskapi", context: "", self: BASE + path};

isolated function user(string accountId, string displayName, string? email = ()) returns UserDTO => {
    accountId,
    displayName,
    emailAddress: email ?: "fred@example-corp.io",
    active: true,
    timeZone: "Australia/Sydney",
    links: {self: BASE_JIRA + "/user?accountId=" + accountId, jiraRest: BASE_JIRA + "/user?accountId=" + accountId}
};

isolated function organization(string id, string name) returns OrganizationDTO => {
    id,
    name,
    uuid: "8a3e1f2c-6b5d-4c7a-9e0f-1d2c3b4a5e6f",
    scimManaged: false,
    created: date("2026-01-15T08:00:00.000+0000"),
    links: {self: BASE + "/organization/" + id}
};

isolated function serviceDesk(string id) returns ServiceDeskDTO => {
    id,
    projectId: "11001",
    projectName: "IT Help Desk",
    projectKey: "SD",
    projectTypeKey: "service_desk",
    links: {self: BASE + "/servicedesk/" + id}
};

isolated function queue(int id) returns QueueDTO => {
    id: id.toString(),
    name: "Unassigned issues",
    jql: "project = SD AND assignee is EMPTY AND resolution = Unresolved ORDER BY \"Time to resolution\" ASC",
    fields: ["issuetype", "issuekey", "summary", "created", "reporter", "duedate"],
    issueCount: 10,
    links: {self: BASE + "/servicedesk/10001/queue/" + id.toString()}
};

isolated function requestType(string id, string serviceDeskId) returns RequestTypeDTO => {
    id,
    serviceDeskId,
    portalId: "2",
    issueTypeId: "10006",
    name: "Get IT help",
    description: "Get IT help for hardware, software or access problems",
    helpText: "Please tell us what you need help with",
    groupIds: ["12"],
    canCreateRequest: true,
    restrictionStatus: "OPEN",
    links: {self: BASE + "/servicedesk/" + serviceDeskId + "/requesttype/" + id}
};

isolated function customerRequest(string issueId, string issueKey) returns CustomerRequestDTO => {
    issueId,
    issueKey,
    summary: "Request JSD help via REST",
    requestTypeId: "11001",
    serviceDeskId: "10001",
    createdDate: date("2026-09-28T09:00:00.000+0000"),
    reporter: user("qm:a713c8ea-1075-4e30-9d96-891a7d181739:5ad6d69abfa3980ce712caae", "Fred F. User"),
    currentStatus: {status: "Waiting for support", statusCategory: "NEW", statusDate: date("2026-09-28T09:00:00.000+0000")},
    requestFieldValues: [{fieldId: "summary", label: "What do you need?", value: "Request JSD help via REST"}],
    links: {
        web: "https://your-domain.atlassian.net/servicedesk/customer/portal/2/" + issueKey,
        jiraRest: BASE_JIRA + "/issue/" + issueId,
        self: BASE + "/request/" + issueId
    }
};

isolated function approval(string id, "approved"|"declined"|"pending" decision) returns ApprovalDTO => {
    id,
    name: "Please approve this request",
    finalDecision: decision,
    canAnswerApproval: decision == "pending",
    approvers: [{approver: user("qm:a713c8ea-1075-4e30-9d96-891a7d181739:3f7e9a2b1c4d", "Alice Approver"), approverDecision: decision}],
    createdDate: date("2026-09-28T09:30:00.000+0000"),
    links: {self: BASE + "/request/10010/approval/" + id}
};

isolated function comment(string id, string body) returns CommentDTO => {
    id,
    body,
    'public: true,
    author: user("qm:a713c8ea-1075-4e30-9d96-891a7d181739:5ad6d69abfa3980ce712caae", "Fred F. User"),
    created: date("2026-09-28T10:00:00.000+0000"),
    links: {self: BASE + "/request/10010/comment/" + id}
};

// Service-mode response types. `bal openapi --mode client` collapses 4XX/5XX
// to `error` and never emits these, so they are defined here for the mock only.
public type ApprovalDTOOk record {|
    *http:Ok;
    ApprovalDTO body;
|};

public type ErrorResponseBadRequest record {|
    *http:BadRequest;
    ErrorResponse body;
|};

public type ErrorResponseConflict record {|
    *http:Conflict;
    ErrorResponse body;
|};

public type ErrorResponseForbidden record {|
    *http:Forbidden;
    ErrorResponse body;
|};

public type ErrorResponseInternalServerError record {|
    *http:InternalServerError;
    ErrorResponse body;
|};

public type ErrorResponseNotFound record {|
    *http:NotFound;
    ErrorResponse body;
|};

public type ErrorResponsePayloadTooLarge record {|
    *http:PayloadTooLarge;
    ErrorResponse body;
|};

public type ErrorResponseUnauthorized record {|
    *http:Unauthorized;
    ErrorResponse body;
|};

public type FormValidationErrorResponseDTOUnprocessableEntity record {|
    *http:UnprocessableEntity;
    FormValidationErrorResponseDTO body;
|};

public type PagedDTOUserDTOOk record {|
    *http:Ok;
    PagedDTOUserDTO body;
|};

public type RequestTypeDTOOk record {|
    *http:Ok;
    RequestTypeDTO body;
|};

# Error returned by the Jira Service Management API
public type ErrorResponse record {|
    # Human-readable error message
    string errorMessage?;
    # Internationalized form of the error message
    I18nErrorMessage i18nErrorMessage?;
|};

# Validation errors reported for a form
public type FormValidationErrorResponseDTO record {|
    # Description of the error
    string errorMessage?;
    # Internationalized error message details
    I18nErrorMessageDTO i18nErrorMessage?;
    # A list of validation errors
    FormValidationErrorDTO[] errors?;
|};

# Internationalized error message key and parameters
public type I18nErrorMessage record {|
    # Key of the internationalized message
    string i18nKey?;
    # Parameters substituted into the message
    string[] parameters?;
|};

# Internationalized error message key and parameters
public type I18nErrorMessageDTO record {|
    # Internationalization key for the error message
    string i18nKey?;
    # Parameters used to render the internationalized error message
    string[] parameters?;
|};
