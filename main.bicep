// @sys.description('The environment type (nonprod or prod)')
// @allowed([
//  'nonprod'
//  'prod'
// ])
// param environmentType string = 'nonprod'

@sys.description('The PostgreSQL Server name')
@minLength(3)
@maxLength(24)
param postgreSQLServerName string = 'adelatorre-dbsrv-dev'

@sys.description('The PostgreSQL Database name')
@minLength(3)
@maxLength(24)
param postgreSQLDatabaseName string = 'adelatorre-db-dev'

@sys.description('The App Service Plan name')
@minLength(3)
@maxLength(24)
param appServicePlanName string = 'adelatorre-asp-dev'

@sys.description('The Web App name (frontend)')
@minLength(3)
@maxLength(24)
param appServiceAppName string = 'adelatorre-frontend-dev'

@sys.description('The API App name (backend)')
@minLength(3)
@maxLength(24)
param appServiceAPIAppName string = 'adelatorre-backend-dev'

@sys.description('The Azure location where the resources will be deployed')
param location string = resourceGroup().location

@sys.description('The value for the environment variable ENV')
param appServiceAPIEnvVarENV string

@sys.description('The value for the environment variable DBHOST')
param appServiceAPIEnvVarDBHOST string

@sys.description('The value for the environment variable DBNAME')
param appServiceAPIEnvVarDBNAME string

@sys.description('The value for the environment variable DBPASS')
@secure()
param appServiceAPIEnvVarDBPASS string

@sys.description('The value for the environment variable DBUSER')
param appServiceAPIDBHostDBUSER string

@sys.description('The value for the environment variable FLASK_APP')
param appServiceAPIDBHostFLASK_APP string

@sys.description('The value for the environment variable FLASK_RUN_PORT')
param appServiceAPIDBHostFLASK_RUN_PORT string

@sys.description('The value for the environment variable FLASK_DEBUG')
param appServiceAPIDBHostFLASK_DEBUG string

@sys.description('The SKU for the PostgreSQL server')
param postgreSQLServerSkuName string = 'Standard_B1ms'

@sys.description('The tier for the PostgreSQL server')
param postgreSQLServerSkuTier string = 'Burstable'

@sys.description('The SKU for the App Service Plan')
param appServicePlanSkuName string = 'B1'

@sys.description('The tier for the App Service Plan')
param appServicePlanSkuTier string = 'Basic'

resource postgresSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: postgreSQLServerName
  location: location
  sku: {
    name: postgreSQLServerSkuName
    tier: postgreSQLServerSkuTier
  }
  properties: {
    administratorLogin: 'iebankdbadmin'
    administratorLoginPassword: 'IE.Bank.DB.Admin.Pa$$'
    createMode: 'Default'
    highAvailability: {
      mode: 'Disabled'
      standbyAvailabilityZone: ''
    }
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    version: '15'
  }

  resource postgresSQLServerFirewallRules 'firewallRules@2022-12-01' = {
    name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
    properties: {
      endIpAddress: '0.0.0.0'
      startIpAddress: '0.0.0.0'
    }
  }
}

resource postgresSQLDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  name: postgreSQLDatabaseName
  parent: postgresSQLServer
  properties: {
    charset: 'UTF8'
    collation: 'en_US.UTF8'
  }
}

module appService 'modules/app-service.bicep' = {
  name: 'appService'
  params: {
    location: location
    // environmentType: environmentType
    appServiceAppName: appServiceAppName
    appServiceAPIAppName: appServiceAPIAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    appServicePlanSkuTier: appServicePlanSkuTier
    appServiceAPIDBHostDBUSER: appServiceAPIDBHostDBUSER
    appServiceAPIDBHostFLASK_APP: appServiceAPIDBHostFLASK_APP
    appServiceAPIDBHostFLASK_RUN_PORT: appServiceAPIDBHostFLASK_RUN_PORT
    appServiceAPIDBHostFLASK_DEBUG: appServiceAPIDBHostFLASK_DEBUG
    appServiceAPIEnvVarDBHOST: appServiceAPIEnvVarDBHOST
    appServiceAPIEnvVarDBNAME: appServiceAPIEnvVarDBNAME
    appServiceAPIEnvVarDBPASS: appServiceAPIEnvVarDBPASS
    appServiceAPIEnvVarENV: appServiceAPIEnvVarENV
  }
  dependsOn: [
    postgresSQLDatabase
  ]
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
