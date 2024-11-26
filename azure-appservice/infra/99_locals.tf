locals {
  project         = "${var.prefix}-${var.env_short}"
  health_path     = "/health"
  docker_registry = "https://ghcr.io"
  docker_image    = "${var.github.org}/${var.github.repository}/azure-appservice:latest"
}
