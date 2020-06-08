resource "azurerm_template_deployment" "event_grid" {
  name                = "event-grid-deployment"
  resource_group_name = var.rg_name

  template_body = <<DEPLOY
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storageName": {
            "type": "string",
            "metadata": {
                "description": "Provide a unique name for the Blob Storage account."
            }
        },
        "eventSubName": {
            "type": "string",
            "defaultValue": "subscribeToStorage",
            "metadata": {
                "description": "Provide a name for the Event Grid subscription."
            }
        },
        "sbQueueId": {
            "type": "string",
            "metadata": {
                "description": "Provide the resource id for the EventHub to receive events."
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.Storage/storageAccounts/providers/eventSubscriptions",
            "name": "[concat(parameters('storageName'), '/Microsoft.EventGrid/', parameters('eventSubName'))]",
            "apiVersion": "2019-06-01",
            "properties": {
                "destination": {
                    "endpointType": "ServiceBusQueue",
                    "properties": {
                        "resourceId": "[parameters('sbQueueId')]"
                    }
                },
                "filter": {
                    "includedEventTypes": [
                        "Microsoft.Storage.BlobCreated"
                    ]
                },
                "eventDeliverySchema": "EventGridSchema"
            }
        }
    ]
}
DEPLOY

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    storageName  = var.storage_account_name
    eventSubName = var.event_grid_sub_name
    sbQueueId    = var.sb_queue_id
  }

  deployment_mode = "Incremental"
}