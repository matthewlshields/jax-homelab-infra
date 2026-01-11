terraform {
  backend "s3" {
    bucket         = "REPLACE_ME_tfstate_bucket"
    key            = "jax-data/tofu.tfstate"
    region         = "us-east-1"

    encrypt        = true
    use_lockfile   = true

    # Optional if you use a non-default AWS profile on the runner container:
    # profile      = "default"
  }
}
