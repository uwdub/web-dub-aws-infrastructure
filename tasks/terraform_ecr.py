from dataclasses import dataclass
import invoke
from invoke import Collection, task
import json
import os
import os.path
from pathlib import Path
from typing import Dict, Optional

from tasks.terraform import write_terraform_variables

ECR_NAMES = [
    "web-dub/web-dub",
]

PATH_STAGING = Path("./.staging")

PATH_TERRAFORM_BIN = Path("./.bin/terraform_1.7.4_windows_amd64/terraform.exe")
PATH_TERRAFORM_DIR = Path("./terraform/ecr")
PATH_STAGING_TERRAFORM_VARIABLES = Path(PATH_STAGING, "terraform/ecr.tfvars")


@task
def task_terraform_apply(context):
    """
    Issue a Terraform apply.
    """

    write_terraform_variables(
        terraform_variables_path=PATH_STAGING_TERRAFORM_VARIABLES,
        terraform_variables_dict={
            "names": ECR_NAMES,
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
            "names": ECR_NAMES,
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


class terraform_output_ecr:
    @dataclass
    class TerraformOutputEcr:
        registry_url: str
        repository_urls: Dict[str, str]

    _context: invoke.Context
    _cached_output: Optional[TerraformOutputEcr]

    """
    """

    def __init__(self, context):
        self._context = context
        self._cached_output = None

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        pass

    @property
    def output(self):
        if self._cached_output is None:
            with self._context.cd(PATH_TERRAFORM_DIR):
                result = self._context.run(
                    command=" ".join(
                        [
                            os.path.relpath(PATH_TERRAFORM_BIN, PATH_TERRAFORM_DIR),
                            "output",
                            "-json",
                        ]
                    ),
                )

            output_json = json.loads(result.stdout.strip())

            self._cached_output = self.TerraformOutputEcr(
                registry_url=output_json["registry_url"]["value"],
                repository_urls=output_json["repository_urls"]["value"],
            )

        return self._cached_output


# Build task collection
ns = Collection("ecr")

ns.add_task(task_terraform_apply, "apply")
ns.add_task(task_terraform_destroy, "destroy")
