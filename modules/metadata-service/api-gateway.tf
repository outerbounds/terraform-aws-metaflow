resource "aws_api_gateway_rest_api_policy" "this" {
  count       = var.enable_api_gateway && length(var.access_list_cidr_blocks) > 0 ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  policy      = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "arn:${var.iam_partition}:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this[0].id}/*/*/*"
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "arn:${var.iam_partition}:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this[0].id}/*/*/*",
            "Condition": {
                "NotIpAddress": {
                    "aws:SourceIp": ${jsonencode(var.access_list_cidr_blocks)}
                }
            }
        }
    ]
  }
  EOF
}

resource "aws_api_gateway_rest_api" "this" {
  count       = var.enable_api_gateway ? 1 : 0
  name        = "${var.resource_prefix}api${var.resource_suffix}"
  description = "Allows access to the Metadata service RDS instance"

  endpoint_configuration {
    types = [local.api_gateway_endpoint_configuration_type]
  }

  tags = var.standard_tags
}

resource "aws_api_gateway_resource" "this" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  parent_id   = aws_api_gateway_rest_api.this[0].root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_resource" "db" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  parent_id   = aws_api_gateway_rest_api.this[0].root_resource_id
  path_part   = "db_schema_status"
}

resource "aws_api_gateway_vpc_link" "this" {
  count       = var.enable_api_gateway ? 1 : 0
  name        = "${var.resource_prefix}vpclink${var.resource_suffix}"
  target_arns = [var.nlb_arn == "" ? aws_lb.this[0].arn : var.nlb_arn]

  tags = var.standard_tags
}

resource "aws_api_gateway_method" "this" {
  count            = var.enable_api_gateway ? 1 : 0
  http_method      = "ANY"
  resource_id      = aws_api_gateway_resource.this[0].id
  rest_api_id      = aws_api_gateway_rest_api.this[0].id
  authorization    = "NONE"
  api_key_required = var.enable_api_basic_auth

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "db" {
  count            = var.enable_api_gateway ? 1 : 0
  http_method      = "GET"
  resource_id      = aws_api_gateway_resource.db[0].id
  rest_api_id      = aws_api_gateway_rest_api.this[0].id
  authorization    = "NONE"
  api_key_required = var.enable_api_basic_auth
}

resource "aws_api_gateway_integration_response" "this" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.this[0].id
  http_method = aws_api_gateway_method.this[0].http_method
  status_code = 200
  depends_on  = [aws_api_gateway_integration.this[0]]
}

resource "aws_api_gateway_integration" "this" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.this[0].id
  http_method = aws_api_gateway_method.this[0].http_method

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.this.dns_name}/{proxy}"
  integration_http_method = "ANY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this[0].id
}

resource "aws_api_gateway_integration" "db" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.db[0].id
  http_method = aws_api_gateway_method.db[0].http_method


  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.this.dns_name}:8082/db_schema_status"
  integration_http_method = "GET"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this[0].id
}

resource "aws_api_gateway_method_response" "this" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.this[0].id
  http_method = aws_api_gateway_method.this[0].http_method
  status_code = "200"
  depends_on  = [aws_api_gateway_integration.this[0]]
}

resource "aws_api_gateway_method_response" "db" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.db[0].id
  http_method = aws_api_gateway_method.db[0].http_method
  status_code = "200"
  depends_on  = [aws_api_gateway_integration.db[0]]
}

resource "aws_api_gateway_deployment" "this" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id

  # explicit depends_on required to ensure module stands up on first `apply`
  # otherwise a second followup `apply` would be required
  # can read more here: https://stackoverflow.com/a/42783769
  depends_on = [aws_api_gateway_method.this[0], aws_api_gateway_integration.this[0]]

  # ensures properly ordered re-deployments occur
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  count         = var.enable_api_gateway ? 1 : 0
  deployment_id = aws_api_gateway_deployment.this[0].id
  rest_api_id   = aws_api_gateway_rest_api.this[0].id
  stage_name    = local.api_gateway_stage_name

  tags = var.standard_tags
}

resource "aws_api_gateway_api_key" "this" {
  count = var.enable_api_gateway && var.enable_api_basic_auth ? 1 : 0
  name  = local.api_gateway_key_name

  tags = var.standard_tags
}

resource "aws_api_gateway_usage_plan" "this" {
  count = var.enable_api_gateway && var.enable_api_basic_auth ? 1 : 0
  name  = local.api_gateway_usage_plan_name

  api_stages {
    api_id = aws_api_gateway_rest_api.this[0].id
    stage  = aws_api_gateway_stage.this[0].stage_name
  }

  tags = var.standard_tags
}

resource "aws_api_gateway_usage_plan_key" "this" {
  count         = var.enable_api_gateway && var.enable_api_basic_auth ? 1 : 0
  key_id        = aws_api_gateway_api_key.this[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[0].id
}
