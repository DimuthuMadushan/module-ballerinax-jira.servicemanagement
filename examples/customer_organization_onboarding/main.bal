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

// Onboards a new client company to a service desk: create an organization for it, give
// the organization access to the service desk, create the company's first customer
// account, add that customer to the organization, then list the organization's members.

import ballerina/io;
import ballerinax/jira.servicemanagement as jsm;

configurable string serviceUrl = ?;
configurable string email = ?;
configurable string apiToken = ?;
configurable string serviceDeskId = ?;
configurable string organizationName = ?;
configurable string customerEmail = ?;
configurable string customerDisplayName = ?;

public function main() returns error? {
    jsm:Client jira = check new ({auth: {username: email, password: apiToken}}, serviceUrl);

    // Step 1: create the organization. Jira returns the existing one if the name is taken.
    jsm:OrganizationDTO organization = check jira->createOrganization({name: organizationName});
    string? organizationKey = organization.id;
    if organizationKey is () {
        return error("The organization has no ID");
    }
    int:Signed32 organizationId = check int:fromString(organizationKey).ensureType();
    io:println(string `Organization '${organizationName}' has ID ${organizationKey}`);

    // Step 2: give the organization access to the service desk.
    check jira->addOrganization(serviceDeskId, {organizationId});

    // Step 3: create the customer account, or reuse it if the email is already registered.
    string accountId;
    jsm:UserDTO|error customer = jira->createCustomer({email: customerEmail, displayName: customerDisplayName});
    if customer is jsm:UserDTO {
        string? createdId = customer.accountId;
        if createdId is () {
            return error("The new customer has no account ID");
        }
        accountId = createdId;
        io:println(string `Created customer ${customerDisplayName} (${accountId})`);
    } else {
        string? existingId = check findCustomerAccountId(jira, customerEmail);
        if existingId is () {
            return customer;
        }
        accountId = existingId;
        io:println(string `Customer ${customerEmail} already exists (${accountId})`);
    }

    // Step 4: make the customer a member of the organization.
    check jira->addUsersToOrganization(organizationId, {accountIds: [accountId]});

    // Step 5: confirm, reading every page of the member list.
    int:Signed32 pageSize = 50;
    int:Signed32 offset = 0;
    string[] members = [];
    while true {
        jsm:PagedDTOUserDTO page = check jira->getUsersInOrganization(organizationId, 'start = offset, 'limit = pageSize);
        jsm:UserDTO[] users = page.values ?: [];
        foreach jsm:UserDTO user in users {
            members.push(user.displayName ?: user.accountId ?: "(unknown)");
        }
        if page.isLastPage != false || users.length() == 0 {
            break;
        }
        offset = <int:Signed32>(offset + users.length());
    }
    io:println(string `'${organizationName}' now has ${members.length()} member(s): `, members);
}

// Looks up an existing customer of the service desk by email, reading every page of matches.
function findCustomerAccountId(jsm:Client jira, string customerEmail) returns string?|error {
    int:Signed32 offset = 0;
    while true {
        jsm:PagedDTOUserDTO page = check jira->getCustomers(serviceDeskId, query = customerEmail, 'start = offset);
        jsm:UserDTO[] users = page.values ?: [];
        foreach jsm:UserDTO user in users {
            if user.emailAddress == customerEmail {
                return user.accountId;
            }
        }
        if page.isLastPage != false || users.length() == 0 {
            return ();
        }
        offset = <int:Signed32>(offset + users.length());
    }
}
