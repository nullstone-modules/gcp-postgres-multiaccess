resource "restapi_object" "role" {
  path         = "/roles"
  id_attribute = "name"
  object_id    = local.username
  force_new    = [local.username]
  destroy_path = "/skip"

  data = jsonencode({
    name        = local.username
    password    = random_password.this.result
    useExisting = true
  })
}

locals {
  superuser_role = "cloudsqlsuperuser"
}

resource "restapi_object" "superuser_role_member" {
  path         = "/roles/${local.superuser_role}/members"
  id_attribute = "member"
  object_id    = "${local.superuser_role}::${local.username}"
  force_new    = [local.superuser_role, local.username]
  destroy_path = "/skip"

  data = jsonencode({
    target      = local.superuser_role
    member      = local.username
    useExisting = true
  })

  depends_on = [
    restapi_object.role
  ]
}

resource "restapi_object" "role_member" {
  path         = "/roles/${local.database_owner}/members"
  id_attribute = "member"
  object_id    = "${local.database_owner}::${local.username}"
  force_new    = [local.database_owner, local.username]
  destroy_path = "/skip"

  data = jsonencode({
    target      = local.database_owner
    member      = local.username
    useExisting = true
  })

  depends_on = [
    restapi_object.database_owner,
    restapi_object.role
  ]
}

resource "restapi_object" "schema_privileges" {
  path         = "/databases/${local.database_name}/schema_privileges"
  id_attribute = "role"
  object_id    = "${local.database_name}::${local.username}"
  force_new    = [local.database_name, local.username]
  destroy_path = "/skip"

  data = jsonencode({
    database = local.database_name
    role     = local.username
  })

  depends_on = [
    restapi_object.database,
    restapi_object.role
  ]
}

resource "restapi_object" "default_grants" {
  path         = "/roles/${local.username}/default_grants"
  id_attribute = "id"
  object_id    = "${local.username}::${local.database_owner}::${local.database_name}"
  force_new    = [local.username, local.database_owner, local.database_name]
  destroy_path = "/skip"

  data = jsonencode({
    role     = local.username
    target   = local.database_owner
    database = local.database_name
  })

  depends_on = [
    restapi_object.role,
    restapi_object.database,
    restapi_object.database_owner
  ]
}

# the following resources are created for each additional database

resource "restapi_object" "additional_role_member" {
  for_each = coalesce(var.additional_database_names, [])

  path         = "/roles/${each.key}/members"
  id_attribute = "member"
  object_id    = "${each.key}::${local.username}"
  force_new    = [each.key, local.username]
  destroy_path = "/skip"

  data = jsonencode({
    target      = each.key
    member      = local.username
    useExisting = true
  })

  depends_on = [
    restapi_object.additional_database_owner,
    restapi_object.role
  ]
}

resource "restapi_object" "additional_schema_privileges" {
  for_each = coalesce(var.additional_database_names, [])

  path         = "/databases/${each.key}/schema_privileges"
  id_attribute = "role"
  object_id    = "${each.key}::${local.username}"
  force_new    = [each.key, local.username]
  destroy_path = "/skip"

  data = jsonencode({
    database = each.key
    role     = local.username
  })

  depends_on = [
    restapi_object.additional_database,
    restapi_object.role
  ]
}

resource "restapi_object" "additional_default_grants" {
  for_each = coalesce(var.additional_database_names, [])

  path         = "/roles/${local.username}/default_grants"
  id_attribute = "id"
  object_id    = "${local.username}::${each.key}::${each.key}"
  force_new    = [local.username, each.key, each.key]
  destroy_path = "/skip"

  data = jsonencode({
    role     = local.username
    target   = each.key
    database = each.key
  })

  depends_on = [
    restapi_object.role,
    restapi_object.additional_database,
    restapi_object.additional_database_owner
  ]
}
