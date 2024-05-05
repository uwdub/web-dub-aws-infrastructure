from pathlib import Path

ALB_NAME = "web-dub-app"
CODEPIPELINE_NAME = "web-dub-codepipeline"
CODEBUILD_NAME = "web-dub-codebuild"
GIT_REPOSITORY_ID = "uwdub/web-dub"
GIT_REPOSITORY_BRANCH = "master"

ECR_REPOSITORY_NAME = "uwdub/web-dub"

ECS_TASK_NAME = "web-dub"

# Each availability zone results in a public IP,
# associated with the application load balancer.
# Billed at $.005 per hour, each public IP is ~$3 per month.
# DUB website does not need that over-redundancy.
# ALB requires a minimum of two availability zones.
NETWORK_AVAILABILITY_ZONES = [
    "us-east-1a",
    # "us-east-1b",
    # "us-east-1c",
    "us-east-1d",
    # "us-east-1e",
    # "us-east-1f",
]

PATH_CODEBUILD_SOURCE = Path("./codebuild")

PATH_STAGING = Path("./.staging")
PATH_STAGING_CODEBUILD_DIR = Path(PATH_STAGING, "codebuild")
PATH_STAGING_CODEBUILD_ARCHIVE = Path(PATH_STAGING_CODEBUILD_DIR, "archive.zip")
PATH_STAGING_CODEBUILD_SOURCE = Path(PATH_STAGING_CODEBUILD_DIR, "source")

PATH_TERRAFORM_BIN = Path("./.bin/terraform_1.7.4_windows_amd64/terraform.exe")
