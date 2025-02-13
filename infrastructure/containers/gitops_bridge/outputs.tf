output "argocd" {
  description = "Argocd helm release"
  value       = try(helm_release.argocd[0], null)
  sensitive = true
}
output "cluster" {
  description = "ArgoCD cluster"
  value       = try(kubernetes_secret_v1.cluster[0], null)
  sensitive = true
}
output "apps" {
  description = "ArgoCD apps"
  value       = try(helm_release.bootstrap, null)
  sensitive = true
}
