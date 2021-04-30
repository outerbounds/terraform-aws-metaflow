resource "aws_api_gateway_rest_api_policy" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  policy      = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/*/*"
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/*/*",
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
  name        = "${var.resource_prefix}api${var.resource_suffix}"
  description = "Allows access to the Metadata service RDS instance"

  tags = var.standard_tags
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_vpc_link" "this" {
  name        = "${var.resource_prefix}vpclink${var.resource_suffix}"
  target_arns = [aws_lb.this.arn]

  tags = var.standard_tags
}

resource "aws_api_gateway_method" "this" {
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration_response" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = 200
  depends_on  = [aws_api_gateway_integration.this]
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.this.dns_name}/{proxy}"
  integration_http_method = "ANY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id
}

resource "aws_api_gateway_method_response" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = "200"
  depends_on  = [aws_api_gateway_integration.this]
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = "api"
  # explicit depends_on required to ensure module stands up on first `apply`
  # otherwise a second followup `apply` would be required
  # can read more here: https://stackoverflow.com/a/42783769
  depends_on = [aws_api_gateway_method.this, aws_api_gateway_integration.this]

  # ensures properly ordered re-deployments occur
  lifecycle {
    create_before_destroy = true
  }
}
