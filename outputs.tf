output "env" {
  value = [
    {
      name  = "POSTGRES_HOST"
      value = local.db_subdomain
    },
    {
      name  = "POSTGRES_USER"
      value = local.username
    },
    {
      name  = "POSTGRES_DB"
      value = local.database_name
    },
    {
      name  = "POSTGRES_SSL_MODE"
      value = local.postgres_ssl_mode
    }
  ]
}

output "secrets" {
  value = [
    {
      name  = "POSTGRES_PASSWORD"
      value = random_password.this.result
    },
    {
      name  = "POSTGRES_URL"
      value = local.postgres_url
    }
  ]
}
