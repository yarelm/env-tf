
locals {
  region = "us-central1"
  zone   = "us-central1-c"
  tenants = ["moshe", "simon"]
}

provider "google" {
  project     = var.gcp_project
  region      = local.region
  zone        = local.zone
  credentials = var.google_credentials
}

module "pg" {
  source = "../../modules/pg"
  region = local.region
  name = "personal-db"
}

module "pg_data" {
  source = "../../modules/pg_data"
  for_each = toset(local.tenants)
  env = each.key
  instance_name = module.pg.instance_name
  depends_on = [module.pg]
}

module "pubsub" {
  source = "../../modules/pubsub"
  for_each = toset(local.tenants)
  env = each.key
}

module "scheduler" {
  source = "../../modules/scheduler"
  count = length(local.tenants)
  env = local.tenants[count.index]
  topic_id = values(module.pubsub)[count.index].delivery_topic_id
}