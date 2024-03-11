from invoke import Collection, task
import os
import os.path
from pathlib import Path
import shutil

from tasks.constants import (
    CODEBUILD_NAME,
    CODEPIPELINE_NAME,
    GIT_REPOSITORY_ID,
    GIT_REPOSITORY_BRANCH,
    PATH_CODEBUILD_SOURCE,
    PATH_STAGING,
    PATH_STAGING_CODEBUILD_ARCHIVE,
    PATH_STAGING_CODEBUILD_DIR,
    PATH_STAGING_CODEBUILD_SOURCE,
    PATH_TERRAFORM_BIN,
)
from tasks.terraform import write_terraform_variables


PATH_TERRAFORM_DIR = Path("./terraform/codepipeline")
PATH_STAGING_TERRAFORM_VARIABLES = Path(PATH_STAGING, "terraform/codepipeline.tfvars")


@task
def task_create_codebuild_archive(context):
    """
    Prepare the CodeBuild archive for Terraform to upload.
    """

    # Remove any prior CodeBuild staging
    shutil.rmtree(path=PATH_STAGING_CODEBUILD_DIR, ignore_errors=True)

    # Copy archive source into a staging directory
    shutil.copytree(src=PATH_CODEBUILD_SOURCE, dst=PATH_STAGING_CODEBUILD_SOURCE)

    # Make the archive
    shutil.make_archive(
        # Remove the zip suffix because make_archive will also apply that suffix
        base_name=str(
            Path(
                PATH_STAGING_CODEBUILD_ARCHIVE.parent,
                PATH_STAGING_CODEBUILD_ARCHIVE.stem,
            )
        ),
        format="zip",
        root_dir=PATH_STAGING_CODEBUILD_SOURCE,
    )


@task(pre=[task_create_codebuild_archive])
def task_terraform_apply(context):
    """
    Issue a Terraform apply.
    """

    write_terraform_variables(
        terraform_variables_path=PATH_STAGING_TERRAFORM_VARIABLES,
        terraform_variables_dict={
            "name_codepipeline": CODEPIPELINE_NAME,
            "name_codebuild": CODEBUILD_NAME,
            "source_archive_codebuild": os.path.relpath(
                PATH_STAGING_CODEBUILD_ARCHIVE, PATH_TERRAFORM_DIR
            ),
            "git_repository_id": GIT_REPOSITORY_ID,
            "git_repository_branch": GIT_REPOSITORY_BRANCH,
        },
    )

    with context.cd(PATH_TERRAFORM_DIR):
        # Ensure initialized
        context.run(
            command=" ".join(
                [
                    os.path.relpath(PATH_TERRAFORM_BIN, PATH_TERRAFORM_DIR),
                    "init",
                ]
            ),
            echo=True,
        )
        # Ensure modules
        context.run(
            command=" ".join(
                [
                    os.path.relpath(PATH_TERRAFORM_BIN, PATH_TERRAFORM_DIR),
                    "get",
                    "-update",
                ]
            ),
            echo=True,
        )
        # Perform apply
        context.run(
            command=" ".join(
                filter(
                    None,
                    [
                        os.path.relpath(PATH_TERRAFORM_BIN, PATH_TERRAFORM_DIR),
                        "apply",
                        '-var-file="{}"'.format(
                            os.path.relpath(
                                PATH_STAGING_TERRAFORM_VARIABLES,
                                PATH_TERRAFORM_DIR,
                            )
                        ),
                    ],
                )
            ),
            echo=True,
        )


@task
def task_terraform_destroy(context):
    """
    Issue a Terraform destroy.
    """

    write_terraform_variables(
        terraform_variables_path=PATH_STAGING_TERRAFORM_VARIABLES,
        terraform_variables_dict={
            "name": CODEPIPELINE_NAME,
            "git_repository_id": GIT_REPOSITORY_ID,
            "git_repository_branch": GIT_REPOSITORY_BRANCH,
        },
    )

    with context.cd(PATH_TERRAFORM_DIR):
        # Ensure initialized
        context.run(
            command=" ".join(
                [
                    os.path.relpath(PATH_TERRAFORM_BIN, PATH_TERRAFORM_DIR),
                    "init",
                ]
            ),
            echo=True,
        )
        # Ensure modules
        context.run(
            command=" ".join(
                [
                    os.path.relpath(PATH_TERRAFORM_BIN, PATH_TERRAFORM_DIR),
                    "get",
                    "-update",
                ]
            ),
            echo=True,
        )
        # Perform destroy
        context.run(
            command=" ".join(
                filter(
                    None,
                    [
                        os.path.relpath(PATH_TERRAFORM_BIN, PATH_TERRAFORM_DIR),
                        "destroy",
                        '-var-file="{}"'.format(
                            os.path.relpath(
                                PATH_STAGING_TERRAFORM_VARIABLES,
                                PATH_TERRAFORM_DIR,
                            )
                        ),
                    ],
                )
            ),
            echo=True,
        )


# Build task collection
ns = Collection("codepipeline")

ns.add_task(task_terraform_apply, "apply")
ns.add_task(task_terraform_destroy, "destroy")
