_Author_:  @DimuthuMadushan \
_Created_: 29-09-2026 \
_Updated_: 29-09-2026 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Jira Service Management.
The OpenAPI specification is obtained from [wso2/api-specs](https://github.com/wso2/api-specs/blob/main/openapi/jira/servicemanagement/1001.0.0/openapi.json).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

`docs/spec/openapi.json` is the unmodified source specification. Every change below is applied to
`docs/spec/aligned_ballerina_openapi.json`, after `bal openapi flatten` and `bal openapi align`.

## Sanitization Details

1. **Keep the site root as the server URL**: `align` folds the shared `/rest/servicedeskapi` prefix into the server URL. It is moved back into every path, so `servers[0].url` stays `https://your-domain.atlassian.net`.
   - **Reason**: Jira Service Management is reached either at the site URL (API token) or through the Atlassian gateway, `https://api.atlassian.com/ex/jira/<cloud-id>` (OAuth 2.0). Both put `/rest/servicedeskapi` after the root, so the caller supplies only the root. The published 1.3.1 `serviceUrl` keeps working.
   - **Re-apply**: `python3 tooling/sanitize_spec.py --spec docs/spec/aligned_ballerina_openapi.json --canonical-server https://your-domain.atlassian.net`.

2. **Operation IDs that the source spec duplicates**: The source spec reuses eight operation IDs across two paths each. The IDs published in 1.3.1 are kept, and the new operations get distinct names:
   - `GET /servicedesk/{serviceDeskId}/knowledgebase/article` → `getArticlesByServiceDeskId`
   - `GET /servicedesk/{serviceDeskId}/organization` → `getOrganizationsByServiceDeskId`
   - The request type property operations under `/servicedesk/{serviceDeskId}/requesttype/{requestTypeId}/property` → `getPropertiesKeysByServiceDeskId`, `getPropertyByServiceDeskId`, `setPropertyByServiceDeskId` and `deletePropertyByServiceDeskId`
   - `POST /customer/skip-permission-check` → `createCustomerSkipPermissionCheck`
   - `POST /servicedesk/{serviceDeskId}/customer/skip-permission-check` → `addCustomersSkipPermissionCheck`
   - `POST /request/{issueIdOrKey}/attachment` keeps the published `createAttachment`. The source spec calls it `createCommentWithAttachment`.
   - **Reason**: Remote method names must be unique, and renaming published methods would break 1.x callers. The decisions are persisted in `docs/spec/ai-mappings.json`.

3. **Multipart body of `attachTemporaryFile`**: The source request body is `multipart/form-data` with `type: array` of a Java `MultipartFile` bean. It is replaced with a new `AttachTemporaryFileRequest` schema that has a single required `file` part (`type: string`, `format: binary`). The `MultipartFile` and `Resource` schemas, which nothing else references, are removed.
   - **Reason**: Jira expects a multipart part named `file`. The source schema describes the server-side Java object, not the wire format.

4. **`X-Atlassian-Token` header on `attachTemporaryFile`**: An optional `X-Atlassian-Token` header parameter is added, with `default: no-check` and `x-ballerina-name: xAtlassianToken`.
   - **Reason**: The operation description says Jira blocks multipart requests without this XSRF header. The default makes the client send it without any action by the caller.

5. **Typed response for `attachTemporaryFile`**: The `201` response had only an example. It now references a new `TemporaryAttachments` schema (`temporaryAttachments: TemporaryAttachment[]`, each with `temporaryAttachmentId` and `fileName`), taken from that example.
   - **Reason**: This makes the method return `TemporaryAttachments` instead of untyped `json`, so the IDs can be passed to `createAttachment`.

6. **Binary attachment downloads**: The `200` responses of `getAttachmentContent` and `getAttachmentThumbnail` declared `application/json` with an empty schema. They are changed to `application/octet-stream` with `type: string`, `format: binary`.
   - **Reason**: These endpoints return the file bytes, so a JSON binding would fail. The `303` redirect that Jira can send is kept, so the method returns `byte[]|error?`. Set `followRedirects` in `ConnectionConfig` to follow it.

7. **Content removed from no-content responses**: The `204` responses of `revokePortalOnlyAccessForUser`, `deleteFeedback` and `addCustomersSkipPermissionCheck` declared `application/json` content with an empty schema. The content is removed.
   - **Reason**: A 204 has no body. With the content removed, the methods return `error?`.

8. **Descriptions filled in**: 86 schemas, 104 properties, 8 parameters and 1 operation had no description, or one under 10 characters. They were given descriptions. Bare `$ref` properties that received one are wrapped as `allOf: [$ref]` so the description is kept. The 19 inline request bodies also received descriptions, and 3 generic `200 response` or `201 response` descriptions were replaced.
   - **Reason**: These descriptions become the doc comments of the generated client and types.

9. **Summaries**: 3 summaries were under 10 characters (`Get info`, `Subscribe`, `Get queue`), and they were expanded. 16 summaries that the source repeats across the duplicated operations in item 2 were qualified by scope, for example `Get organization property` and `Get request type property`.
   - **Reason**: Each generated method needs a distinct doc comment.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json --mode client --license docs/license.txt --client-methods remote -o ballerina
```

Note: The license year is hardcoded to 2026, change if necessary.
