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

// Raises a customer request on a service desk and attaches a supporting file to it:
// find the request type by name, check it takes a summary and a description, create the
// request, upload the file as a temporary attachment, then attach it to the request.

import ballerina/io;
import ballerinax/jira.servicemanagement as jsm;

configurable string serviceUrl = ?;
configurable string email = ?;
configurable string apiToken = ?;
configurable string serviceDeskId = ?;
configurable string requestTypeName = ?;
configurable string summary = ?;
configurable string description = ?;
configurable string attachmentPath = ?;

public function main() returns error? {
    jsm:Client jira = check new ({auth: {username: email, password: apiToken}}, serviceUrl);

    // Step 1: find the request type by name.
    jsm:PagedDTORequestTypeDTO requestTypes = check jira->getRequestTypes(serviceDeskId, searchQuery = requestTypeName);
    jsm:RequestTypeDTO[] matches = from jsm:RequestTypeDTO requestType in requestTypes.values ?: []
        where requestType.name == requestTypeName
        select requestType;
    if matches.length() == 0 {
        return error(string `No request type named '${requestTypeName}' in service desk ${serviceDeskId}`);
    }
    string? requestTypeId = matches[0].id;
    if requestTypeId is () {
        return error("The request type has no ID");
    }

    // Step 2: make sure the request type collects the two fields this example fills in.
    int:Signed32 typeId = check int:fromString(requestTypeId).ensureType();
    jsm:CustomerRequestCreateMetaDTO meta = check jira->getRequestTypeFields(serviceDeskId, typeId);
    string[] fieldIds = from jsm:RequestTypeFieldDTO 'field in meta.requestTypeFields ?: []
        select 'field.fieldId ?: "";
    foreach string required in ["summary", "description"] {
        if fieldIds.indexOf(required) is () {
            return error(string `Request type '${requestTypeName}' has no '${required}' field`);
        }
    }

    // Step 3: raise the request.
    jsm:CustomerRequestDTO request = check jira->createCustomerRequest({
        serviceDeskId,
        requestTypeId,
        requestFieldValues: {"summary": summary, "description": description}
    });
    string? issueKey = request.issueKey;
    if issueKey is () {
        return error("The created request has no issue key");
    }
    io:println("Created request ", issueKey);

    // Step 4: upload the file as a temporary attachment on the service desk.
    byte[] content = check io:fileReadBytes(attachmentPath);
    string fileName = fileNameOf(attachmentPath);
    jsm:TemporaryAttachments uploaded = check jira->attachTemporaryFile(serviceDeskId, {
        file: {fileContent: content, fileName}
    });
    string[] temporaryAttachmentIds = from jsm:TemporaryAttachment attachment in uploaded.temporaryAttachments ?: []
        select attachment.temporaryAttachmentId ?: "";
    if temporaryAttachmentIds.length() == 0 || temporaryAttachmentIds.indexOf("") !is () {
        return error("The upload returned no temporary attachment ID");
    }

    // Step 5: attach it to the request, with a comment the customer can see.
    jsm:AttachmentCreateResultDTO attached = check jira->createAttachment(issueKey, {
        temporaryAttachmentIds,
        'public: true,
        additionalComment: {body: string `Attached ${fileName}.`}
    });
    int count = (attached.attachments?.values ?: []).length();
    io:println(string `Attached ${count} file(s) to ${issueKey}`);
    string? portalLink = request.links?.web;
    if portalLink is string {
        io:println("View it on the portal: ", portalLink);
    }
}

isolated function fileNameOf(string path) returns string {
    int? slash = path.lastIndexOf("/");
    return slash is int ? path.substring(slash + 1) : path;
}
