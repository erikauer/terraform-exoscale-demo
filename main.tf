# Entry Point
# https://www.terraform.io/docs/modules/create.html

module "kubernetes_infrastructure" {
  source = "./modules/kubernetes_infrastructure"
}
