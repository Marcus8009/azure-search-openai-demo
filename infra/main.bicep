// targetScope = 'subscription'
targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

param appServicePlanName string = '' // Set in main.parameters.json
param backendServiceName string = '' // Set in main.parameters.json
param resourceGroupName string = '' // Set in main.parameters.json

param applicationInsightsDashboardName string = '' // Set in main.parameters.json
param applicationInsightsName string = '' // Set in main.parameters.json
param logAnalyticsName string = '' // Set in main.parameters.json

param searchServiceName string = '' // Set in main.parameters.json
param searchServiceResourceGroupName string = '' // Set in main.parameters.json
param searchServiceLocation string = '' // Set in main.parameters.json
// The free tier does not support managed identity (required) or semantic search (optional)
@allowed(['free', 'basic', 'standard', 'standard2', 'standard3', 'storage_optimized_l1', 'storage_optimized_l2'])
param searchServiceSkuName string // Set in main.parameters.json
param searchIndexName string // Set in main.parameters.json
param searchQueryLanguage string // Set in main.parameters.json
param searchQuerySpeller string // Set in main.parameters.json
param searchServiceSemanticRankerLevel string // Set in main.parameters.json
var actualSearchServiceSemanticRankerLevel = (searchServiceSkuName == 'free')
  ? 'disabled'
  : searchServiceSemanticRankerLevel
param searchServiceQueryRewriting string // Set in main.parameters.json
param storageAccountName string = '' // Set in main.parameters.json
param storageResourceGroupName string = '' // Set in main.parameters.json
param storageResourceGroupLocation string = location
param storageContainerName string = 'content'
param storageSkuName string // Set in main.parameters.json

param userStorageAccountName string = ''
param userStorageContainerName string = 'user-content'

param tokenStorageContainerName string = 'tokens'

param appServiceSkuName string // Set in main.parameters.json

@allowed(['azure', 'openai', 'azure_custom'])
param openAiHost string // Set in main.parameters.json
param isAzureOpenAiHost bool = startsWith(openAiHost, 'azure')
param deployAzureOpenAi bool = openAiHost == 'azure'
param azureOpenAiCustomUrl string = ''
param azureOpenAiApiVersion string = ''
@secure()
param azureOpenAiApiKey string = ''
param azureOpenAiDisableKeys bool = false
param openAiServiceName string = ''
param openAiResourceGroupName string = ''

param useEval bool = false


// https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=python-secure%2Cstandard%2Cstandard-chat-completions#standard-deployment-model-availability
@description('Location for the OpenAI resource group')
@allowed([
  'canadaeast'
  'eastus'
  'eastus2'
  'francecentral'
  'switzerlandnorth'
  'uksouth'
  'japaneast'
  'northcentralus'
  'australiaeast'
  'swedencentral'
])
@metadata({
  azd: {
    type: 'location'
  }
})
param openAiLocation string

param openAiSkuName string = 'S0'

@secure()
param openAiApiKey string = ''
param openAiApiOrganization string = ''

param documentIntelligenceServiceName string = '' // Set in main.parameters.json
param documentIntelligenceResourceGroupName string = '' // Set in main.parameters.json

// Limited regions for new version:
// https://learn.microsoft.com/azure/ai-services/document-intelligence/concept-layout
@description('Location for the Document Intelligence resource group')
@allowed(['eastus', 'westus2', 'westeurope'])
@metadata({
  azd: {
    type: 'location'
  }
})
param documentIntelligenceResourceGroupLocation string

param documentIntelligenceSkuName string // Set in main.parameters.json

param contentUnderstandingServiceName string = '' // Set in main.parameters.json
param contentUnderstandingResourceGroupName string = '' // Set in main.parameters.json

param chatGptModelName string = ''
param chatGptDeploymentName string = ''
param chatGptDeploymentVersion string = ''
param chatGptDeploymentSkuName string = ''
param chatGptDeploymentCapacity int = 0

var chatGpt = {
  modelName: !empty(chatGptModelName)
    ? chatGptModelName
    : startsWith(openAiHost, 'azure') ? 'gpt-4.1-nano' : 'gpt-4.1-nano'
  deploymentName: !empty(chatGptDeploymentName) ? chatGptDeploymentName : 'chat'
  deploymentVersion: !empty(chatGptDeploymentVersion) ? chatGptDeploymentVersion : '2025-04-14'
  deploymentSkuName: !empty(chatGptDeploymentSkuName) ? chatGptDeploymentSkuName : 'Standard'
  deploymentCapacity: chatGptDeploymentCapacity != 0 ? chatGptDeploymentCapacity : 30
}

param embeddingModelName string = ''
param embeddingDeploymentName string = ''
param embeddingDeploymentVersion string = ''
param embeddingDeploymentSkuName string = ''
param embeddingDeploymentCapacity int = 0
param embeddingDimensions int = 0
var embedding = {
  modelName: !empty(embeddingModelName) ? embeddingModelName : 'text-embedding-ada-002'
  deploymentName: !empty(embeddingDeploymentName) ? embeddingDeploymentName : 'embedding'
  deploymentVersion: !empty(embeddingDeploymentVersion) ? embeddingDeploymentVersion : '2'
  deploymentSkuName: !empty(embeddingDeploymentSkuName) ? embeddingDeploymentSkuName : 'Standard'
  deploymentCapacity: embeddingDeploymentCapacity != 0 ? embeddingDeploymentCapacity : 30
  dimensions: embeddingDimensions != 0 ? embeddingDimensions : 1536
}


param evalModelName string = ''
param evalDeploymentName string = ''
param evalModelVersion string = ''
param evalDeploymentSkuName string = ''
param evalDeploymentCapacity int = 0
var eval = {
  modelName: !empty(evalModelName) ? evalModelName : 'gpt-4o'
  deploymentName: !empty(evalDeploymentName) ? evalDeploymentName : 'gpt-4o'
  deploymentVersion: !empty(evalModelVersion) ? evalModelVersion : '2024-08-06'
  deploymentSkuName: !empty(evalDeploymentSkuName) ? evalDeploymentSkuName : 'Standard'
  deploymentCapacity: evalDeploymentCapacity != 0 ? evalDeploymentCapacity : 30
}


param tenantId string = tenant().tenantId
param authTenantId string = ''

// Used for the optional login and document level access control system
param useAuthentication bool = false
param enforceAccessControl bool = false
// Force using MSAL app authentication instead of built-in App Service authentication
// https://learn.microsoft.com/azure/app-service/overview-authentication-authorization
param disableAppServicesAuthentication bool = false
param enableGlobalDocuments bool = false
param enableUnauthenticatedAccess bool = false
param serverAppId string = ''
@secure()
param serverAppSecret string = ''
param clientAppId string = ''
@secure()
param clientAppSecret string = ''

// Used for optional CORS support for alternate frontends
param allowedOrigin string = '' // should start with https://, shouldn't end with a /

@allowed(['None', 'AzureServices'])
@description('If allowedIp is set, whether azure services are allowed to bypass the storage and AI services firewall.')
param bypass string = 'AzureServices'

@description('Public network access value for all deployed resources')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'

@description('Add a private endpoints for network connectivity')
param usePrivateEndpoint bool = false

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('Use Application Insights for monitoring and performance tracing')
param useApplicationInsights bool = false

@description('Enable language picker')
param enableLanguagePicker bool = false
@description('Use chat history feature in browser')
param useChatHistoryBrowser bool = false
@description('Show options to use vector embeddings for searching in the app UI')
param useVectors bool = false
@description('Use Built-in integrated Vectorization feature of AI Search to vectorize and ingest documents')
param useIntegratedVectorization bool = false

@description('Use media description feature with Azure Content Understanding during ingestion')
param useMediaDescriberAzureCU bool = true

@description('Enable user document upload feature')
param useUserUpload bool = false
param useLocalPdfParser bool = false
param useLocalHtmlParser bool = false

@description('Use AI project')
param useAiProject bool = false

var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = 'marcus'
var tags = { 'azd-env-name': environmentName }

var tenantIdForAuth = !empty(authTenantId) ? authTenantId : tenantId
var authenticationIssuerUri = '${environment().authentication.loginEndpoint}${tenantIdForAuth}/v2.0'

@description('Whether the deployment is running on GitHub Actions')
param runningOnGh string = ''

@description('Whether the deployment is running on Azure DevOps Pipeline')
param runningOnAdo string = ''

@description('Used by azd for containerapps deployment')
param webAppExists bool

@allowed(['Consumption', 'D4', 'D8', 'D16', 'D32', 'E4', 'E8', 'E16', 'E32', 'NC24-A100', 'NC48-A100', 'NC96-A100'])
param azureContainerAppsWorkloadProfile string

@allowed(['appservice', 'containerapps'])
param deploymentTarget string = 'appservice'
param acaIdentityName string = deploymentTarget == 'containerapps' ? '${environmentName}-aca-identity' : ''
param acaManagedEnvironmentName string = deploymentTarget == 'containerapps' ? '${environmentName}-aca-env' : ''
param containerRegistryName string = deploymentTarget == 'containerapps'
  ? '${replace(toLower(environmentName), '-', '')}acr'
  : ''

// Configure CORS for allowing different web apps to use the backend
// For more information please see https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
var msftAllowedOrigins = [ 'https://portal.azure.com', 'https://ms.portal.azure.com' ]
var loginEndpoint = environment().authentication.loginEndpoint
var loginEndpointFixed = lastIndexOf(loginEndpoint, '/') == length(loginEndpoint) - 1 ? substring(loginEndpoint, 0, length(loginEndpoint) - 1) : loginEndpoint
var allMsftAllowedOrigins = !(empty(clientAppId)) ? union(msftAllowedOrigins, [ loginEndpointFixed ]) : msftAllowedOrigins
// Combine custom origins with Microsoft origins, remove any empty origin strings and remove any duplicate origins
var allowedOrigins = reduce(filter(union(split(allowedOrigin, ';'), allMsftAllowedOrigins), o => length(trim(o)) > 0), [], (cur, next) => union(cur, [next]))

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
  scope: subscription(subscription().subscriptionId)
}

// Monitor application with Azure Monitor
module monitoring 'core/monitor/monitoring.bicep' = if (useApplicationInsights) {
  name: 'monitoring'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    applicationInsightsName: !empty(applicationInsightsName)
      ? applicationInsightsName
      : '${abbrs.insightsComponents}${resourceToken}'
    logAnalyticsName: !empty(logAnalyticsName)
      ? logAnalyticsName
      : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    publicNetworkAccess: publicNetworkAccess
  }
}

module applicationInsightsDashboard 'backend-dashboard.bicep' = if (useApplicationInsights) {
  name: 'application-insights-dashboard'
  scope: resourceGroup
  params: {
    name: !empty(applicationInsightsDashboardName)
      ? applicationInsightsDashboardName
      : '${abbrs.portalDashboards}${resourceToken}'
    location: location
    applicationInsightsName: useApplicationInsights ? monitoring.outputs.applicationInsightsName : ''
  }
}

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan 'core/host/appserviceplan.bicep' = if (deploymentTarget == 'appservice') {
  name: 'appserviceplan'
  scope: resourceGroup
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: appServiceSkuName
      capacity: 1
    }
    kind: 'linux'
  }
}

var appEnvVariables = {
  AZURE_STORAGE_ACCOUNT: storage.outputs.name
  AZURE_STORAGE_CONTAINER: storageContainerName
  AZURE_SEARCH_INDEX: searchIndexName
  AZURE_SEARCH_SERVICE: searchService.outputs.name
  AZURE_SEARCH_SEMANTIC_RANKER: actualSearchServiceSemanticRankerLevel
  AZURE_SEARCH_QUERY_REWRITING: searchServiceQueryRewriting
  AZURE_SEARCH_QUERY_LANGUAGE: searchQueryLanguage
  AZURE_SEARCH_QUERY_SPELLER: searchQuerySpeller
  APPLICATIONINSIGHTS_CONNECTION_STRING: useApplicationInsights
    ? monitoring.outputs.applicationInsightsConnectionString
    : ''
  ENABLE_LANGUAGE_PICKER: enableLanguagePicker
  // Chat history settings
  USE_CHAT_HISTORY_BROWSER: useChatHistoryBrowser
  // Shared by all OpenAI deployments
  OPENAI_HOST: openAiHost
  AZURE_OPENAI_EMB_MODEL_NAME: embedding.modelName
  AZURE_OPENAI_EMB_DIMENSIONS: embedding.dimensions
  AZURE_OPENAI_CHATGPT_MODEL: chatGpt.modelName
  // Specific to Azure OpenAI
  AZURE_OPENAI_SERVICE: isAzureOpenAiHost && deployAzureOpenAi ? openAi.outputs.name : ''
  AZURE_OPENAI_CHATGPT_DEPLOYMENT: chatGpt.deploymentName
  AZURE_OPENAI_EMB_DEPLOYMENT: embedding.deploymentName
  AZURE_OPENAI_API_VERSION: azureOpenAiApiVersion
  AZURE_OPENAI_API_KEY_OVERRIDE: azureOpenAiApiKey
  AZURE_OPENAI_CUSTOM_URL: azureOpenAiCustomUrl
  // Used only with non-Azure OpenAI deployments
  OPENAI_API_KEY: openAiApiKey
  OPENAI_ORGANIZATION: openAiApiOrganization
  // Optional login and document level access control system
  AZURE_USE_AUTHENTICATION: useAuthentication
  AZURE_ENFORCE_ACCESS_CONTROL: enforceAccessControl
  AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS: enableGlobalDocuments
  AZURE_ENABLE_UNAUTHENTICATED_ACCESS: enableUnauthenticatedAccess
  AZURE_SERVER_APP_ID: serverAppId
  AZURE_CLIENT_APP_ID: clientAppId
  AZURE_TENANT_ID: tenantId
  AZURE_AUTH_TENANT_ID: tenantIdForAuth
  AZURE_AUTHENTICATION_ISSUER_URI: authenticationIssuerUri
  // CORS support, for frontends on other hosts
  ALLOWED_ORIGIN: join(allowedOrigins, ';')
  USE_VECTORS: useVectors
  USE_USER_UPLOAD: useUserUpload
  AZURE_USERSTORAGE_ACCOUNT: useUserUpload ? userStorage.outputs.name : ''
  AZURE_USERSTORAGE_CONTAINER: useUserUpload ? userStorageContainerName : ''
  AZURE_DOCUMENTINTELLIGENCE_SERVICE: documentIntelligence.outputs.name
  USE_LOCAL_PDF_PARSER: useLocalPdfParser
  USE_LOCAL_HTML_PARSER: useLocalHtmlParser
  USE_MEDIA_DESCRIBER_AZURE_CU: useMediaDescriberAzureCU
  AZURE_CONTENTUNDERSTANDING_ENDPOINT: useMediaDescriberAzureCU ? contentUnderstanding.outputs.endpoint : ''
  RUNNING_IN_PRODUCTION: 'true'
  HASHED_API_KEY: 'f3282794f91208416abfb687683a6de9416217e0d6defeb20e19cb15eb00619f'
  FORWARD_ENDPOINT: 'https://rag-management.greengrass-4086dbcc.eastus.azurecontainerapps.io'
}

// App Service for the web application (Python Quart app with JS frontend)
module backend 'core/host/appservice.bicep' = if (deploymentTarget == 'appservice') {
  name: 'web'
  scope: resourceGroup
  params: {
    name: !empty(backendServiceName) ? backendServiceName : '${abbrs.webSitesAppService}backend-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'backend' })
    // Need to check deploymentTarget again due to https://github.com/Azure/bicep/issues/3990
    appServicePlanId: deploymentTarget == 'appservice' ? appServicePlan.outputs.id : ''
    runtimeName: 'python'
    runtimeVersion: '3.11'
    appCommandLine: 'python3 -m gunicorn main:app'
    scmDoBuildDuringDeployment: true
    managedIdentity: true
    virtualNetworkSubnetId: isolation.outputs.appSubnetId
    publicNetworkAccess: publicNetworkAccess
    allowedOrigins: allowedOrigins
    clientAppId: clientAppId
    serverAppId: serverAppId
    enableUnauthenticatedAccess: enableUnauthenticatedAccess
    disableAppServicesAuthentication: disableAppServicesAuthentication
    clientSecretSettingName: !empty(clientAppSecret) ? 'AZURE_CLIENT_APP_SECRET' : ''
    authenticationIssuerUri: authenticationIssuerUri
    use32BitWorkerProcess: appServiceSkuName == 'F1'
    alwaysOn: appServiceSkuName != 'F1'
    appSettings: union(appEnvVariables, {
      AZURE_SERVER_APP_SECRET: serverAppSecret
      AZURE_CLIENT_APP_SECRET: clientAppSecret
    })
  }
}

// Azure container apps resources (Only deployed if deploymentTarget is 'containerapps')

// User-assigned identity for pulling images from ACR
module acaIdentity 'core/security/aca-identity.bicep' = if (deploymentTarget == 'containerapps') {
  name: 'aca-identity'
  scope: resourceGroup
  params: {
    identityName: acaIdentityName
    location: location
  }
}

module containerApps 'core/host/container-apps.bicep' = if (deploymentTarget == 'containerapps') {
  name: 'container-apps'
  scope: resourceGroup
  params: {
    name: 'app'
    tags: tags
    location: location
    workloadProfile: azureContainerAppsWorkloadProfile
    containerAppsEnvironmentName: acaManagedEnvironmentName
    containerRegistryName: '${containerRegistryName}${resourceToken}'
    logAnalyticsWorkspaceResourceId: useApplicationInsights ? monitoring.outputs.logAnalyticsWorkspaceId : ''
  }
}

// Container Apps for the web application (Python Quart app with JS frontend)
module acaBackend 'core/host/container-app-upsert.bicep' = if (deploymentTarget == 'containerapps') {
  name: 'aca-web'
  scope: resourceGroup
  dependsOn: [
    containerApps
    acaIdentity
  ]
  params: {
    name: !empty(backendServiceName) ? backendServiceName : '${abbrs.webSitesContainerApps}backend-${resourceToken}'
    location: location
    identityName: (deploymentTarget == 'containerapps') ? acaIdentityName : ''
    exists: webAppExists
    workloadProfile: azureContainerAppsWorkloadProfile
    containerRegistryName: (deploymentTarget == 'containerapps') ? containerApps.outputs.registryName : ''
    containerAppsEnvironmentName: (deploymentTarget == 'containerapps') ? containerApps.outputs.environmentName : ''
    identityType: 'UserAssigned'
    tags: union(tags, { 'azd-service-name': 'backend' })
    targetPort: 8000
    containerCpuCoreCount: '1.0'
    containerMemory: '2Gi'
    containerMinReplicas: 1
    allowedOrigins: allowedOrigins
    env: union(appEnvVariables, {
      // For using managed identity to access Azure resources. See https://github.com/microsoft/azure-container-apps/issues/442
      AZURE_CLIENT_ID: (deploymentTarget == 'containerapps') ? acaIdentity.outputs.clientId : ''
      })
    secrets: useAuthentication ? {
      azureclientappsecret: clientAppSecret
      azureserverappsecret: serverAppSecret
    } : {}
    envSecrets: useAuthentication ? [
      {
        name: 'AZURE_CLIENT_APP_SECRET'
        secretRef: 'azureclientappsecret'
      }
      {
        name: 'AZURE_SERVER_APP_SECRET'
        secretRef: 'azureserverappsecret'
      }
    ] : []
  }
}

module acaAuth 'core/host/container-apps-auth.bicep' = if (deploymentTarget == 'containerapps' && !empty(clientAppId)) {
  name: 'aca-auth'
  scope: resourceGroup
  params: {
    name: acaBackend.outputs.name
    clientAppId: clientAppId
    serverAppId: serverAppId
    clientSecretSettingName: !empty(clientAppSecret) ? 'azureclientappsecret' : ''
    authenticationIssuerUri: authenticationIssuerUri
    enableUnauthenticatedAccess: enableUnauthenticatedAccess
    blobContainerUri: 'https://${storageAccountName}.blob.${environment().suffixes.storage}/${tokenStorageContainerName}'
    appIdentityResourceId: (deploymentTarget == 'appservice') ? '' : acaBackend.outputs.identityResourceId
  }
}

var defaultOpenAiDeployments = [
  {
    name: chatGpt.deploymentName
    model: {
      format: 'OpenAI'
      name: chatGpt.modelName
      version: chatGpt.deploymentVersion
    }
    sku: {
      name: chatGpt.deploymentSkuName
      capacity: chatGpt.deploymentCapacity
    }
  }
  {
    name: embedding.deploymentName
    model: {
      format: 'OpenAI'
      name: embedding.modelName
      version: embedding.deploymentVersion
    }
    sku: {
      name: embedding.deploymentSkuName
      capacity: embedding.deploymentCapacity
    }
  }
]

var openAiDeployments = concat(
  defaultOpenAiDeployments,
  useEval
    ? [
      {
        name: eval.deploymentName
        model: {
          format: 'OpenAI'
          name: eval.modelName
          version: eval.deploymentVersion
        }
        sku: {
          name: eval.deploymentSkuName
          capacity: eval.deploymentCapacity
        }
      }
    ] : []
)

module openAi 'br/public:avm/res/cognitive-services/account:0.7.2' = if (isAzureOpenAiHost && deployAzureOpenAi) {
  name: 'openai'
  scope: resourceGroup
  params: {
    name: !empty(openAiServiceName) ? openAiServiceName : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    location: openAiLocation
    tags: tags
    kind: 'OpenAI'
    customSubDomainName: !empty(openAiServiceName)
      ? openAiServiceName
      : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Allow'
      bypass: bypass
    }
    sku: openAiSkuName
    deployments: openAiDeployments
    disableLocalAuth: azureOpenAiDisableKeys
  }
}

// Formerly known as Form Recognizer
// Does not support bypass
module documentIntelligence 'br/public:avm/res/cognitive-services/account:0.7.2' = {
  name: 'documentintelligence'
  scope: resourceGroup
  params: {
    name: !empty(documentIntelligenceServiceName)
      ? documentIntelligenceServiceName
      : '${abbrs.cognitiveServicesDocumentIntelligence}${resourceToken}'
    kind: 'FormRecognizer'
    customSubDomainName: !empty(documentIntelligenceServiceName)
      ? documentIntelligenceServiceName
      : '${abbrs.cognitiveServicesDocumentIntelligence}${resourceToken}'
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Allow'
    }
    location: documentIntelligenceResourceGroupLocation
    disableLocalAuth: false
    tags: tags
    sku: documentIntelligenceSkuName
  }
}


module contentUnderstanding 'br/public:avm/res/cognitive-services/account:0.7.2' = if (useMediaDescriberAzureCU) {
  name: 'content-understanding'
  scope: resourceGroup
  params: {
    name: !empty(contentUnderstandingServiceName)
      ? contentUnderstandingServiceName
      : '${abbrs.cognitiveServicesContentUnderstanding}${resourceToken}'
    kind: 'AIServices'
    networkAcls: {
      defaultAction: 'Allow'
    }
    customSubDomainName: !empty(contentUnderstandingServiceName)
      ? contentUnderstandingServiceName
      : '${abbrs.cognitiveServicesContentUnderstanding}${resourceToken}'
    // Hard-coding to westus for now, due to limited availability and no overlap with Document Intelligence
    location: 'westus'
    tags: tags
    sku: 'S0'
  }
}

module searchService 'core/search/search-services.bicep' = {
  name: 'search-service'
  scope: resourceGroup
  params: {
    name: !empty(searchServiceName) ? searchServiceName : 'gptkb-${resourceToken}'
    location: !empty(searchServiceLocation) ? searchServiceLocation : location
    tags: tags
    disableLocalAuth: false
    sku: {
      name: searchServiceSkuName
    }
    semanticSearch: actualSearchServiceSemanticRankerLevel
    publicNetworkAccess: publicNetworkAccess == 'Enabled'
      ? 'enabled'
      : (publicNetworkAccess == 'Disabled' ? 'disabled' : null)
    sharedPrivateLinkStorageAccounts: usePrivateEndpoint ? [storage.outputs.id] : []
  }
}

module searchDiagnostics 'core/search/search-diagnostics.bicep' = if (useApplicationInsights) {
  name: 'search-diagnostics'
  scope: resourceGroup
  params: {
    searchServiceName: searchService.outputs.name
    workspaceId: useApplicationInsights ? monitoring.outputs.logAnalyticsWorkspaceId : ''
  }
}

module storage 'core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    name: !empty(storageAccountName) ? storageAccountName : '${abbrs.storageStorageAccounts}${resourceToken}'
    location: storageResourceGroupLocation
    tags: tags
    publicNetworkAccess: publicNetworkAccess
    bypass: bypass
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    sku: {
      name: storageSkuName
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 2
    }
    containers: [
      {
        name: storageContainerName
        publicAccess: 'None'
      }
      {
        name: tokenStorageContainerName
        publicAccess: 'None'
      }
    ]
  }
}

module userStorage 'core/storage/storage-account.bicep' = if (useUserUpload) {
  name: 'user-storage'
  scope: resourceGroup
  params: {
    name: !empty(userStorageAccountName)
      ? userStorageAccountName
      : 'user${abbrs.storageStorageAccounts}${resourceToken}'
    location: storageResourceGroupLocation
    tags: tags
    publicNetworkAccess: publicNetworkAccess
    bypass: bypass
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    isHnsEnabled: true
    sku: {
      name: storageSkuName
    }
    containers: [
      {
        name: userStorageContainerName
        publicAccess: 'None'
      }
    ]
  }
}

module ai 'core/ai/ai-environment.bicep' = if (useAiProject) {
  name: 'ai'
  scope: resourceGroup
  params: {
    location: openAiLocation
    tags: tags
    hubName: 'aihub-${resourceToken}'
    projectName: 'aiproj-${resourceToken}'
    storageAccountId: storage.outputs.id
    applicationInsightsId: !useApplicationInsights ? '' : monitoring.outputs.applicationInsightsId
  }
}


// USER ROLES
var principalType = empty(runningOnGh) && empty(runningOnAdo) ? 'User' : 'ServicePrincipal'

module openAiRoleUser 'core/security/role.bicep' = if (isAzureOpenAiHost && deployAzureOpenAi) {
  scope: resourceGroup
  name: 'openai-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: principalType
  }
}

// For document intelligence
module cognitiveServicesRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'cognitiveservices-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: 'a97b65f3-24c7-4388-baec-2e87135dc908'
    principalType: principalType
  }
}

module storageRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'storage-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
    principalType: principalType
  }
}

module storageContribRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'storage-contrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: principalType
  }
}

module storageOwnerRoleUser 'core/security/role.bicep' = if (useUserUpload) {
  scope: resourceGroup
  name: 'storage-owner-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
    principalType: principalType
  }
}

module searchRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'search-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: principalType
  }
}

module searchContribRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'search-contrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
    principalType: principalType
  }
}

module searchSvcContribRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'search-svccontrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
    principalType: principalType
  }
}



// SYSTEM IDENTITIES
module openAiRoleBackend 'core/security/role.bicep' = if (isAzureOpenAiHost && deployAzureOpenAi) {
  scope: resourceGroup
  name: 'openai-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice')
      ? backend.outputs.identityPrincipalId
      : acaBackend.outputs.identityPrincipalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: 'ServicePrincipal'
  }
}

module openAiRoleSearchService 'core/security/role.bicep' = if (isAzureOpenAiHost && deployAzureOpenAi && useIntegratedVectorization) {
  scope: resourceGroup
  name: 'openai-role-searchservice'
  params: {
    principalId: searchService.outputs.principalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: 'ServicePrincipal'
  }
}

module storageRoleBackend 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'storage-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice')
      ? backend.outputs.identityPrincipalId
      : acaBackend.outputs.identityPrincipalId
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
    principalType: 'ServicePrincipal'
  }
}

module storageOwnerRoleBackend 'core/security/role.bicep' = if (useUserUpload) {
  scope: resourceGroup
  name: 'storage-owner-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice')
      ? backend.outputs.identityPrincipalId
      : acaBackend.outputs.identityPrincipalId
    roleDefinitionId: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
    principalType: 'ServicePrincipal'
  }
}

module storageRoleSearchService 'core/security/role.bicep' = if (useIntegratedVectorization) {
  scope: resourceGroup
  name: 'storage-role-searchservice'
  params: {
    principalId: searchService.outputs.principalId
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
    principalType: 'ServicePrincipal'
  }
}

// Used to issue search queries
// https://learn.microsoft.com/azure/search/search-security-rbac
module searchRoleBackend 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'search-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice')
      ? backend.outputs.identityPrincipalId
      : acaBackend.outputs.identityPrincipalId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: 'ServicePrincipal'
  }
}


module isolation 'network-isolation.bicep' = {
  name: 'networks'
  scope: resourceGroup
  params: {
    deploymentTarget: deploymentTarget
    location: location
    tags: tags
    vnetName: '${abbrs.virtualNetworks}${resourceToken}'
    // Need to check deploymentTarget due to https://github.com/Azure/bicep/issues/3990
    appServicePlanName: deploymentTarget == 'appservice' ? appServicePlan.outputs.name : ''
    usePrivateEndpoint: usePrivateEndpoint
  }
}

var environmentData = environment()

var openAiPrivateEndpointConnection = (isAzureOpenAiHost && deployAzureOpenAi && deploymentTarget == 'appservice')
  ? [
      {
        groupId: 'account'
        dnsZoneName: 'privatelink.openai.azure.com'
        resourceIds: concat(
          [openAi.outputs.resourceId],
          useMediaDescriberAzureCU ? [contentUnderstanding.outputs.resourceId] : [],
          !useLocalPdfParser ? [documentIntelligence.outputs.resourceId] : []
        )
      }
    ]
  : []
var otherPrivateEndpointConnections = (usePrivateEndpoint && deploymentTarget == 'appservice')
  ? [
      {
        groupId: 'blob'
        dnsZoneName: 'privatelink.blob.${environmentData.suffixes.storage}'
        resourceIds: concat([storage.outputs.id], useUserUpload ? [userStorage.outputs.id] : [])
      }
      {
        groupId: 'searchService'
        dnsZoneName: 'privatelink.search.windows.net'
        resourceIds: [searchService.outputs.id]
      }
      {
        groupId: 'sites'
        dnsZoneName: 'privatelink.azurewebsites.net'
        resourceIds: [backend.outputs.id]
      }
    ]
  : []

var privateEndpointConnections = concat(otherPrivateEndpointConnections, openAiPrivateEndpointConnection)

module privateEndpoints 'private-endpoints.bicep' = if (usePrivateEndpoint && deploymentTarget == 'appservice') {
  name: 'privateEndpoints'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    resourceToken: resourceToken
    privateEndpointConnections: privateEndpointConnections
    applicationInsightsId: useApplicationInsights ? monitoring.outputs.applicationInsightsId : ''
    logAnalyticsWorkspaceId: useApplicationInsights ? monitoring.outputs.logAnalyticsWorkspaceId : ''
    vnetName: isolation.outputs.vnetName
    vnetPeSubnetName: isolation.outputs.backendSubnetId
  }
}

// Used to read index definitions (required when using authentication)
// https://learn.microsoft.com/azure/search/search-security-rbac
module searchReaderRoleBackend 'core/security/role.bicep' = if (useAuthentication) {
  scope: resourceGroup
  name: 'search-reader-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice')
      ? backend.outputs.identityPrincipalId
      : acaBackend.outputs.identityPrincipalId
    roleDefinitionId: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
    principalType: 'ServicePrincipal'
  }
}

// Used to add/remove documents from index (required for user upload feature)
module searchContribRoleBackend 'core/security/role.bicep' = if (useUserUpload) {
  scope: resourceGroup
  name: 'search-contrib-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice')
      ? backend.outputs.identityPrincipalId
      : acaBackend.outputs.identityPrincipalId
    roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
    principalType: 'ServicePrincipal'
  }
}


// For document intelligence access by the backend
module documentIntelligenceRoleBackend 'core/security/role.bicep' = if (useUserUpload) {
  scope: resourceGroup
  name: 'documentintelligence-role-backend'
  params: {
    principalId: (deploymentTarget == 'appservice')
      ? backend.outputs.identityPrincipalId
      : acaBackend.outputs.identityPrincipalId
    roleDefinitionId: 'a97b65f3-24c7-4388-baec-2e87135dc908'
    principalType: 'ServicePrincipal'
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenantId
output AZURE_AUTH_TENANT_ID string = authTenantId
output AZURE_RESOURCE_GROUP string = resourceGroup.name

// Shared by all OpenAI deployments
output OPENAI_HOST string = openAiHost
output AZURE_OPENAI_EMB_MODEL_NAME string = embedding.modelName
output AZURE_OPENAI_CHATGPT_MODEL string = chatGpt.modelName

// Specific to Azure OpenAI
output AZURE_OPENAI_SERVICE string = isAzureOpenAiHost && deployAzureOpenAi ? openAi.outputs.name : ''
output AZURE_OPENAI_API_VERSION string = isAzureOpenAiHost ? azureOpenAiApiVersion : ''
output AZURE_OPENAI_RESOURCE_GROUP string = isAzureOpenAiHost ? resourceGroup.name : ''
output AZURE_OPENAI_CHATGPT_DEPLOYMENT string = isAzureOpenAiHost ? chatGpt.deploymentName : ''
output AZURE_OPENAI_EMB_DEPLOYMENT string = isAzureOpenAiHost ? embedding.deploymentName : ''
output AZURE_OPENAI_EVAL_DEPLOYMENT string = isAzureOpenAiHost && useEval ? eval.deploymentName : ''
output AZURE_OPENAI_EVAL_MODEL string = isAzureOpenAiHost && useEval ? eval.modelName : ''


output AZURE_CONTENTUNDERSTANDING_ENDPOINT string = useMediaDescriberAzureCU ? contentUnderstanding.outputs.endpoint : ''

output AZURE_DOCUMENTINTELLIGENCE_SERVICE string = documentIntelligence.outputs.name
output AZURE_DOCUMENTINTELLIGENCE_RESOURCE_GROUP string = resourceGroup.name

output AZURE_SEARCH_INDEX string = searchIndexName
output AZURE_SEARCH_SERVICE string = searchService.outputs.name
output AZURE_SEARCH_SERVICE_RESOURCE_GROUP string = resourceGroup.name
output AZURE_SEARCH_SEMANTIC_RANKER string = actualSearchServiceSemanticRankerLevel
output AZURE_SEARCH_SERVICE_ASSIGNED_USERID string = searchService.outputs.principalId


output AZURE_STORAGE_ACCOUNT string = storage.outputs.name
output AZURE_STORAGE_CONTAINER string = storageContainerName
output AZURE_STORAGE_RESOURCE_GROUP string = resourceGroup.name

output AZURE_USERSTORAGE_ACCOUNT string = useUserUpload ? userStorage.outputs.name : ''
output AZURE_USERSTORAGE_CONTAINER string = userStorageContainerName
output AZURE_USERSTORAGE_RESOURCE_GROUP string = resourceGroup.name

output AZURE_AI_PROJECT string = useAiProject ? ai.outputs.projectName : ''

output AZURE_USE_AUTHENTICATION bool = useAuthentication

output BACKEND_URI string = deploymentTarget == 'appservice' ? backend.outputs.uri : acaBackend.outputs.uri
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = deploymentTarget == 'containerapps'
  ? containerApps.outputs.registryLoginServer
  : ''
