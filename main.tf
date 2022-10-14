provider "kubernetes" {
  config_path = "~/.kube/config"
}


resource "kubernetes_secret" "regsecret" {
  metadata {
    name = "regsecret"
  }

  data = {
    ".dockerconfigjson" = "${file("~/.docker/config.json")}"
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_deployment" "ngnix-website" {
  metadata {
    name = "ngnix-website"
    labels = {
      app = "website"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "website"
      }
    }

    template {
      metadata {
        labels = {
          app = "website"
        }
      }

      spec {
        container {
          name              = "website"
          image             = "demo.goharbor.io/demo/nginx:latest"
          image_pull_policy = "Always"
          port {
            container_port = "80"
          }
        }
        image_pull_secrets {
          name = kubernetes_secret.regsecret.metadata.0.name
        }
      }
    }
  }
}
