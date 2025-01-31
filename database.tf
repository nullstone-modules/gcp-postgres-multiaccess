resource "restapi_object" "database_owner" {
  path         = "/roles"
  id_attribute = "name"
  object_id    = local.database_name
  force_new    = [local.database_name]
  destroy_path = "/skip"

  data = jsonencode({
    name        = local.database_name
    useExisting = true
  })
}

resource "restapi_object" "database" {
  path         = "/databases"
  id_attribute = "name"
  object_id    = local.database_name
  force_new    = [local.database_name]
  destroy_path = "/skip"

  data = jsonencode({
    name        = local.database_name
    owner       = local.database_owner
    useExisting = true
  })

  depends_on = [restapi_object.database_owner]
}

# the following resources are created for each additional database

resource "restapi_object" "additional_database_owner" {
  for_each = coalesce(var.additional_database_names, [])

  path         = "/roles"
  id_attribute = "name"
  object_id    = each.key
  force_new    = [each.key]
  destroy_path = "/skip"

  data = jsonencode({
    name        = each.key
    useExisting = true
  })
}

resource "restapi_object" "additional_database" {
  for_each = coalesce(var.additional_database_names, [])

  path         = "/databases"
  id_attribute = "name"
  object_id    = each.key
  force_new    = [each.key]
  destroy_path = "/skip"

  data = jsonencode({
    name        = each.key
    owner       = each.key
    useExisting = true
  })

  depends_on = [restapi_object.additional_database_owner]
}
