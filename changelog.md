# Change Log

This file contains all the notable changes done to the Ballerina Jira Service Management connector through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- 14 new operations added: `getAssetsWorkspaces`, `createCustomerSkipPermissionCheck`,
  `revokePortalOnlyAccessForUser`, `viewArticle`, `removeUsersFromOrganization`, `validateCustomerRequest`,
  `getAttachmentContent`, `getAttachmentThumbnail`, `removeRequestParticipants`, `removeCustomers`, `inviteCustomer`,
  `addCustomersSkipPermissionCheck`, `removeOrganization` and `checkRequestTypePermissions`.
- Every operation takes an optional `headers` map, and query parameters are grouped in a `*Queries` record per
  operation.
- `ConnectionConfig` accepts `followRedirects`, which `getAttachmentContent` and `getAttachmentThumbnail` need when
  Jira answers with a `303` redirect to the file.

### Changed

- All 61 operations published in 1.3.1 keep their method names. Their signatures change as follows:
  - Operations with no response body now return `error?` instead of `http:Response|error` or `json|error`:
    `deleteOrganization`, `deleteProperty`, `addUsersToOrganization`, `subscribe`, `unsubscribe`,
    `performCustomerTransition`, `deleteFeedback`, `addCustomers`, `addOrganization`, `deleteRequestType` and
    `deletePropertyByServiceDeskId`.
  - `attachTemporaryFile` now sends a real multipart upload. It takes an `AttachTemporaryFileRequest`
    (`{file: {fileContent, fileName}}`) instead of `byte[]`, sends the `X-Atlassian-Token: no-check` header Jira
    requires, and returns `TemporaryAttachments` instead of `json`.
  - Integer path parameters are `int:Signed32` instead of `int` (`organizationId`, `approvalId`, `requestTypeId`).
    `getRequestTypeById` takes `requestTypeId` as a `string`.
  - `setProperty` and `setPropertyByServiceDeskId` take the property value as a required `json payload`.
  - Query parameters are passed as named arguments, for example `getOrganizations('start = 0, 'limit = 50)`.
    Positional query arguments no longer compile.
- `serviceUrl` is now an optional second argument of `init`, defaulting to `https://your-domain.atlassian.net`.
  Always pass your own site URL, or `https://api.atlassian.com/ex/jira/<cloud-id>` for OAuth 2.0. The path of every
  request still includes `/rest/servicedeskapi`, so a 1.3.1 `serviceUrl` works unchanged.
- The minimum Ballerina distribution is now **2201.12.0** (Swan Lake Update 12), up from 2201.4.1.

### Removed

- The `Linkable`, `LinkableAttachmentLinkDTO`, `LinkableCustomerRequestLinkDTO`, `LinkableUserLinkDTO` and
  `Expandable` record types.
