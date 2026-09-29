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
// read the file, find the request type by name, check it takes a summary and a description
// and nothing else required, create the request, upload the file as a temporary
// attachment, then attach it to the request.

import ballerina/file;
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

    // Step 1: read the attachment first, so a bad path fails before anything is created in Jira.
    byte[] content = check io:fileReadBytes(attachmentPath);
    string fileName = check file:basename(attachmentPath);

    // Step 2: find the request type by name, reading every page of the search results.
    string requestTypeId = check findRequestTypeId(jira);

    // Step 3: make sure the request type collects the two fields this example fills in, and
    // needs no other required field.
    int:Signed32 typeId = check int:fromString(requestTypeId).ensureType();
    jsm:CustomerRequestCreateMetaDTO meta = check jira->getRequestTypeFields(serviceDeskId, typeId);
    jsm:RequestTypeFieldDTO[] fields = meta.requestTypeFields ?: [];
    string[] fieldIds = from jsm:RequestTypeFieldDTO 'field in fields
        select 'field.fieldId ?: "";
    foreach string needed in ["summary", "description"] {
        if fieldIds.indexOf(needed) is () {
            return error(string `Request type '${requestTypeName}' has no '${needed}' field`);
        }
    }
    string[] otherRequired = from jsm:RequestTypeFieldDTO 'field in fields
        let string fieldId = 'field.fieldId ?: ""
        where 'field.required == true && fieldId != "summary" && fieldId != "description"
        select fieldId;
    if otherRequired.length() > 0 {
        return error(string `Request type '${requestTypeName}' requires fields this example does not fill in: ${
            string:'join(", ", ...otherRequired)}`);
    }

    // Step 4: raise the request.
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

    // Step 5: upload the file as a temporary attachment on the service desk.
    jsm:TemporaryAttachments uploaded = check jira->attachTemporaryFile(serviceDeskId, {
        file: {fileContent: content, fileName}
    });
    string[] temporaryAttachmentIds = from jsm:TemporaryAttachment attachment in uploaded.temporaryAttachments ?: []
        select attachment.temporaryAttachmentId ?: "";
    if temporaryAttachmentIds.length() == 0 || temporaryAttachmentIds.indexOf("") !is () {
        return error("The upload returned no temporary attachment ID");
    }

    // Step 6: attach it to the request, with a comment the customer can see.
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

// Pages through the service desk's request types until one matches `requestTypeName` exactly.
function findRequestTypeId(jsm:Client jira) returns string|error {
    int:Signed32 offset = 0;
    while true {
        jsm:PagedDTORequestTypeDTO page = check jira->getRequestTypes(serviceDeskId,
            searchQuery = requestTypeName, 'start = offset);
        jsm:RequestTypeDTO[] requestTypes = page.values ?: [];
        foreach jsm:RequestTypeDTO requestType in requestTypes {
            if requestType.name == requestTypeName {
                string? id = requestType.id;
                if id is () {
                    return error("The request type has no ID");
                }
                return id;
            }
        }
        if page.isLastPage != false || requestTypes.length() == 0 {
            return error(string `No request type named '${requestTypeName}' in service desk ${serviceDeskId}`);
        }
        offset = <int:Signed32>(offset + requestTypes.length());
    }
}
