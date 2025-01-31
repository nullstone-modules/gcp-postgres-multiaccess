data "ns_connection" "postgres" {
  name     = "postgres"
  contract = "datastore/gcp/postgres:*"
}

locals {
  db_name      = data.ns_connection.postgres.outputs.db_instance_name
  db_endpoint  = data.ns_connection.postgres.outputs.db_endpoint
  db_subdomain = split(":", local.db_endpoint)[0]
  db_port      = split(":", local.db_endpoint)[1]
}

locals {
  db_admin_func_name = data.ns_connection.postgres.outputs.db_admin_function_name
  db_admin_func_url  = data.ns_connection.postgres.outputs.db_admin_function_url
  db_admin_invoker   = data.ns_connection.postgres.outputs.db_admin_invoker
}
