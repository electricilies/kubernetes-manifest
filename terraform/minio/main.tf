terraform {
  required_version = ">= 1.13.4"
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 3.11.3"
    }
  }
}

resource "minio_s3_bucket" "electricilies" {
  acl    = "public"
  bucket = "electricilies"
}

resource "minio_ilm_policy" "electricilies_policy" {
  bucket = minio_s3_bucket.electricilies.bucket

  rule {
    id         = "expire-temp-product-images"
    status     = "Enabled"
    filter     = "temp/products/images/"
    expiration = "1d"
  }

  rule {
    id         = "expire-temp-reviews"
    status     = "Enabled"
    filter     = "temp/reviews/images/"
    expiration = "1d"
  }
}
