data "ns_connection" "postgres" {
  name     = "postgres"
  contract = "datastore/gcp/postgres:*"
}

locals {
  db_name      = data.ns_connection.postgres.outputs.db_instance_name
  db_endpoint  = data.ns_connection.postgres.outputs.db_endpoint
  db_subdomain = split(":", local.db_endpoint)[0]
  db_port      = split(":", local.db_endpoint)[1]
  // fallback to "prefer" for old postgres modules
  postgres_ssl_mode = try(data.ns_connection.postgres.outputs.postgres_ssl_mode, "prefer")
}

locals {
  db_admin_func_name = data.ns_connection.postgres.outputs.db_admin_function_name
  db_admin_func_url  = data.ns_connection.postgres.outputs.db_admin_function_url
  db_admin_invoker   = data.ns_connection.postgres.outputs.db_admin_invoker
}

locals {
  postgres_url_opts         = { "sslmode" : local.postgres_ssl_mode }
  postgres_url_prelim_query = join("&", [for k, v in local.postgres_url_opts : "${urlencode(k)}=${urlencode(v)}"])
  postgres_url_query        = local.postgres_url_prelim_query == "" ? "" : "?${local.postgres_url_prelim_query}"
  postgres_url              = "postgres://${urlencode(local.username)}:${urlencode(random_password.this.result)}@${local.db_endpoint}/${urlencode(local.database_name)}${local.postgres_url_query}"
}
