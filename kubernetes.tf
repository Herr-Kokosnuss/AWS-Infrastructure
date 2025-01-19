# Create namespace
resource "kubernetes_namespace" "cocoplanner" {
  metadata {
    name = "cocoplanner"
  }
}

# Create deployment
resource "kubernetes_deployment" "cocoplanner" {
  metadata {
    name      = "cocoplanner"
    namespace = kubernetes_namespace.cocoplanner.metadata[0].name
    labels = {
      app = "cocoplanner"
    }
  }

  spec {
    replicas = 2

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = 1
        max_unavailable = 0
      }
    }

    selector {
      match_labels = {
        app = "cocoplanner"
      }
    }

    template {
      metadata {
        labels = {
          app = "cocoplanner"
        }
      }

      spec {
        container {
          name  = "cocoplanner"
          image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/cocoplanner:latest"

          port {
            container_port = 80
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "200m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }

          # Environment variables referencing manually created secrets
          env {
            name = "SERPER_API_KEY"
            value_from {
              secret_key_ref {
                name = "cocoplanner-secrets"  # This matches your manual secret name
                key  = "serper-api-key"
              }
            }
          }

          env {
            name = "OPENAI_API_KEY"
            value_from {
              secret_key_ref {
                name = "cocoplanner-secrets"
                key  = "openai-api-key"
              }
            }
          }

          env {
            name = "EMAIL_SENDER"
            value_from {
              secret_key_ref {
                name = "cocoplanner-secrets"
                key  = "email-sender"
              }
            }
          }

          env {
            name = "EMAIL_PASSWORD"
            value_from {
              secret_key_ref {
                name = "cocoplanner-secrets"
                key  = "email-password"
              }
            }
          }

          env {
            name = "AMADEUS_API_KEY"
            value_from {
              secret_key_ref {
                name = "cocoplanner-secrets"
                key  = "amadeus-api-key"
              }
            }
          }

          env {
            name = "AMADEUS_API_SECRET"
            value_from {
              secret_key_ref {
                name = "cocoplanner-secrets"
                key  = "amadeus-api-secret"
              }
            }
          }

          env {
            name = "MONGODB_ATLAS_URI"
            value_from {
              secret_key_ref {
                name = "cocoplanner-secrets"
                key  = "mongodb-atlas-uri"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 15
            period_seconds       = 20
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds       = 5
          }
        }
      }
    }
  }
}

# Create service
resource "kubernetes_service" "cocoplanner" {
  metadata {
    name      = "cocoplanner-service"
    namespace = kubernetes_namespace.cocoplanner.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.cocoplanner.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
} 