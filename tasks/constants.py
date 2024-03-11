from pathlib import Path

CODEPIPELINE_NAME = "web-dub-codepipeline"
CODEBUILD_NAME = "web-dub-codebuild"
GIT_REPOSITORY_ID = "uwdub/web-dub"
GIT_REPOSITORY_BRANCH = "master"

PATH_CODEBUILD_SOURCE = Path("./codebuild")

PATH_STAGING = Path("./.staging")
PATH_STAGING_CODEBUILD_DIR = Path(PATH_STAGING, "codebuild")
PATH_STAGING_CODEBUILD_ARCHIVE = Path(PATH_STAGING_CODEBUILD_DIR, "archive.zip")
PATH_STAGING_CODEBUILD_SOURCE = Path(PATH_STAGING_CODEBUILD_DIR, "source")

PATH_TERRAFORM_BIN = Path("./.bin/terraform_1.7.4_windows_amd64/terraform.exe")
