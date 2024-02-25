"""
Tasks for configuring the AWS CLI environment.
"""

import configparser
import dotenv
from invoke import Collection
from invoke import task
from pathlib import Path


PATH_AWS_CONFIGURATIONS = Path("./secrets/aws/profiles.config")
PATH_AWS_ENV = Path("./secrets/aws/.aws_env")


def _task_configure(
    *,
    path_aws_env: Path,
    path_aws_configurations: Path,
    aws_configuration_name: str,
):
    config = configparser.SafeConfigParser()
    config.read(path_aws_configurations)

    config_profile = config["profile {}".format(aws_configuration_name)]

    lines = [
        "# Generated from:",
        "#   config: {}".format(path_aws_configurations),
        "#   profile: {}".format(aws_configuration_name),
        "",
        "{}={}".format(
            "AWS_ACCESS_KEY_ID",
            config_profile["aws_access_key_id"],
        ),
        "{}={}".format(
            "AWS_SECRET_ACCESS_KEY",
            config_profile["aws_secret_access_key"],
        ),
        "{}={}".format(
            "AWS_DEFAULT_REGION",
            config_profile["region"],
        ),
    ]

    with open(path_aws_env, mode="w") as awsenv_file:
        awsenv_file.writelines("{}\n".format(line_current) for line_current in lines)


def apply_aws_env():
    """
    Apply the environment at the provided path, created by a prior configure task.
    """
    if Path(PATH_AWS_ENV).exists():
        dotenv.load_dotenv(
            dotenv_path=PATH_AWS_ENV,
            override=True,
            verbose=True,
        )
    else:
        print(
            'Expected AWS environment configuration not found at "{}"'.format(
                PATH_AWS_ENV
            )
        )


@task
def task_configure_probe(context):
    """
    Configure AWS CLI for probe.
    """

    _task_configure(
        path_aws_env=PATH_AWS_ENV,
        path_aws_configurations=PATH_AWS_CONFIGURATIONS,
        aws_configuration_name="probe",
    )


# Build task collection
ns = Collection("aws")

ns_configure = Collection("configure")
ns_configure.add_task(task_configure_probe, "probe")

ns.add_collection(ns_configure, "configure")
