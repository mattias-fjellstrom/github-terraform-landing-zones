import azure.functions as func
import azurefunctions.extensions.bindings.cosmosdb as cosmos
import json
import os

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


@app.route(route=".well-known/terraform.json", methods=[func.HttpMethod.GET])
def well_known(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse(
        body=json.dumps({"modules.v1": "/terraform/modules/v1/"}),
        status_code=200,
        headers={"Content-Type": "application/json"},
    )


@app.route(
    route="terraform/modules/v1/{namespace}/{name}/{system}/versions",
    methods=[func.HttpMethod.GET],
)
@app.cosmos_db_input(
    arg_name="container",
    database_name=os.environ["COSMOS_DATABASE_NAME"],
    container_name=os.environ["COSMOS_CONTAINER_NAME"],
    connection="CosmosDBConnection",
)
def list_available_versions(
    req: func.HttpRequest, container: cosmos.ContainerProxy
) -> func.HttpResponse:
    query = "SELECT c.id AS version FROM c WHERE c.namespace = @namespace AND c.name = @name AND c.system = @system"
    params = [
        {"name": "@namespace", "value": req.route_params["namespace"]},
        {"name": "@name", "value": req.route_params["name"]},
        {"name": "@system", "value": req.route_params["system"]},
    ]

    items = list(
        container.query_items(
            query=query,
            parameters=params,
            partition_key=[
                req.route_params["namespace"],
                req.route_params["name"],
                req.route_params["system"],
            ],
        )
    )

    return func.HttpResponse(
        body=json.dumps({"modules": [{"versions": items}]}),
        status_code=200,
        headers={"Content-Type": "application/json"},
    )


@app.route(
    trigger_arg_name="req",
    route="terraform/modules/v1/{namespace}/{name}/{system}/{version}/download",
    methods=[func.HttpMethod.GET],
)
@app.cosmos_db_input(
    arg_name="container",
    database_name=os.environ["COSMOS_DATABASE_NAME"],
    container_name=os.environ["COSMOS_CONTAINER_NAME"],
    connection="CosmosDBConnection",
)
def download_version(
    req: func.HttpRequest, container: cosmos.ContainerProxy
) -> func.HttpResponse:
    item = container.read_item(
        item=req.route_params["version"],
        partition_key=[
            req.route_params["namespace"],
            req.route_params["name"],
            req.route_params["system"],
        ],
    )

    return func.HttpResponse(
        status_code=204,
        headers={"X-Terraform-Get": f'{item["url"]}'},
    )


@app.route(
    route="terraform/modules/v1/{namespace}/{name}/{system}/{version}/publish",
    methods=[func.HttpMethod.POST],
)
@app.cosmos_db_output(
    arg_name="document",
    database_name=os.environ["COSMOS_DATABASE_NAME"],
    container_name=os.environ["COSMOS_CONTAINER_NAME"],
    connection="CosmosDBConnection",
)
def publish_version(
    req: func.HttpRequest, document: func.Out[func.Document]
) -> func.HttpResponse:
    body = req.get_json()
    url = body.get("url")

    document.set(
        func.Document.from_dict(
            {
                "id": req.route_params["version"],
                "namespace": req.route_params["namespace"],
                "name": req.route_params["name"],
                "system": req.route_params["system"],
                "url": url,
            }
        )
    )

    return func.HttpResponse(
        status_code=201,
    )
