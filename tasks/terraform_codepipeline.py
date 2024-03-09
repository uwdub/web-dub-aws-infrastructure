from dataclasses import dataclass
import invoke
from invoke import Collection, task
import json
import os
import os.path
from pathlib import Path
from typing import Dict, Optional

from tasks.terraform import write_terraform_variables

CODEPIPELINE_NAME = "web-dub-codepipeline"

PATH_STAGING = Path("./.staging")

PATH_TERRAFORM_BIN = Path("./.bin/terraform_1.7.4_windows_amd64/terraform.exe")
PATH_TERRAFORM_DIR = Path("./terraform/codepipeline")
PATH_STAGING_TERRAFORM_VARIABLES = Path(PATH_STAGING, "terraform/codepipeline.tfvars")


@task
def task_terraform_apply(context):
    """
    Issue a Terraform apply.
    """

    write_terraform_variables(
        terraform_variables_path=PATH_STAGING_TERRAFORM_VARIABLES,
        terraform_variables_dict={
            "name": CODEPIPELINE_NAME,
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
