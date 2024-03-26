from invoke import Collection, task
import os
import os.path
from pathlib import Path

from tasks.constants import (
    PATH_STAGING,
    PATH_TERRAFORM_BIN,
)
from tasks.terraform import write_terraform_variables
from tasks.terraform_alb import TerraformOutputAlb


PATH_TERRAFORM_DIR = Path("./terraform/dns")
PATH_STAGING_TERRAFORM_VARIABLES = Path(PATH_STAGING, "terraform/dns.tfvars")


@task
def task_write_terraform_variables(context):
    with TerraformOutputAlb(context) as alb:
        write_terraform_variables(
            terraform_variables_path=PATH_STAGING_TERRAFORM_VARIABLES,
            terraform_variables_dict={
                "alb_dns_name": alb.output.alb.dns_name,
                "alb_zone_id": alb.output.alb.zone_id,
            },
        )


@task(pre=[task_write_terraform_variables])
def task_terraform_apply(context):
    """
    Issue a Terraform apply.
    """

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


@task(pre=[task_write_terraform_variables])
def task_terraform_destroy(context):
    """
    Issue a Terraform destroy.
    """

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
ns = Collection("dns")

ns.add_task(task_terraform_apply, "apply")
ns.add_task(task_terraform_destroy, "destroy")
