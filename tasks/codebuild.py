import boto3
from invoke import Collection, task
import os
import os.path
from pathlib import Path
import ruamel.yaml
import shutil
import time

from tasks.terraform import write_terraform_variables

CODEBUILD_NAME = "web-dub-codebuild"
PATH_CODEBUILD_SOURCE = Path("./codebuild")

PATH_STAGING = Path("./.staging")

PATH_STAGING_CODEBUILD_DIR = Path(PATH_STAGING, "codebuild")
PATH_STAGING_CODEBUILD_ARCHIVE = Path(PATH_STAGING_CODEBUILD_DIR, "archive.zip")
PATH_STAGING_CODEBUILD_SOURCE = Path(PATH_STAGING_CODEBUILD_DIR, "source")

PATH_TERRAFORM_BIN = Path("./.bin/terraform_1.7.4_windows_amd64/terraform.exe")
PATH_TERRAFORM_DIR = Path("./terraform/codebuild")
PATH_STAGING_TERRAFORM_VARIABLES = Path(PATH_STAGING, "terraform/codebuild.tfvars")


@task
def task_create_codebuild_archive(context):
    """
    Prepare the CodeBuild archive for Terraform to upload.
    """

    # Remove any prior CodeBuild staging
    shutil.rmtree(path=PATH_STAGING_CODEBUILD_DIR, ignore_errors=True)

    # Copy archive source into a staging directory
    shutil.copytree(src=PATH_CODEBUILD_SOURCE, dst=PATH_STAGING_CODEBUILD_SOURCE)

    # Determine whether we need to update the buildspec.yml with environment variables
    # if codebuild_environment_variables_factory is not None:
    #     # Obtain the variables we need to update in the buildspec.yml
    #     codebuild_environment_variables = codebuild_environment_variables_factory(context=context)
    #
    #     # Prefer buildspec.yaml, allow buildspec.yml
    #     buildspec_path = Path(staging_local_source_dir, 'buildspec.yaml')
    #     if not buildspec_path.exists():
    #         buildspec_path = Path(staging_local_source_dir, 'buildspec.yml')
    #
    #     # Use a parsing object for roundtrip
    #     # Invoking a parse without keeping the object will not maintain state for round trip
    #     yaml_parser = ruamel.yaml.YAML()
    #
    #     # Update the buildspec to add provided environment variables
    #     with open(buildspec_path) as file_buildspec:
    #         yaml_buildspec = yaml_parser.load(file_buildspec)
    #
    #     # Ensure the buildspec provides for environment variables
    #     if 'env' not in yaml_buildspec:
    #         yaml_buildspec['env'] = {}
    #     if 'variables' not in yaml_buildspec['env']:
    #         yaml_buildspec['env']['variables'] = {}
    #
    #     # Add the variables
    #     for key_current, value_current in codebuild_environment_variables.items():
    #         yaml_buildspec['env']['variables'][key_current] = value_current
    #
    #     # Replace the buildspec
    #     os.remove(buildspec_path)
    #     with open(buildspec_path, mode='w') as file_buildspec:
    #         yaml_parser.dump(yaml_buildspec, file_buildspec)

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


@task
def task_execute_codebuild(context):
    """
    Execute the build and print any output.
    """

    # Obtain an authorization token.
    # boto will obtain AWS context from environment variables, but will have obtained those at an unknown time.
    # Creating a boto session ensures it uses the current value of AWS configuration environment variables.
    boto_session = boto3.Session()
    boto_cloudwatchlogs = boto_session.client("logs")
    boto_codebuild = boto_session.client("codebuild")

    # Start the build
    response = boto_codebuild.start_build(projectName=CODEBUILD_NAME)
    build_id = response["build"]["id"]

    # Loop on the build until logs become available
    in_progress = True
    logs_next_token = None
    while in_progress:
        # Determine whether the build is still executing
        response_build = boto_codebuild.batch_get_builds(ids=[build_id])["builds"][0]
        in_progress = response_build["buildStatus"] == "IN_PROGRESS"

        # If the logs have been created
        if (
            "groupName" in response_build["logs"]
            and "streamName" in response_build["logs"]
        ):
            # Print any logs that are currently available
            events_available = True
            while events_available:
                if logs_next_token is None:
                    response_logs = boto_cloudwatchlogs.get_log_events(
                        logGroupName=response_build["logs"]["groupName"],
                        logStreamName=response_build["logs"]["streamName"],
                        startFromHead=True,
                    )
                else:
                    response_logs = boto_cloudwatchlogs.get_log_events(
                        logGroupName=response_build["logs"]["groupName"],
                        logStreamName=response_build["logs"]["streamName"],
                        nextToken=logs_next_token,
                        startFromHead=True,
                    )

                for event_current in response_logs["events"]:
                    print(event_current["message"], end="", flush=True)

                events_available = response_logs["nextForwardToken"] != logs_next_token
                logs_next_token = response_logs["nextForwardToken"]

        if in_progress:
            # Any faster will likely encounter rate limiting
            time.sleep(0.5)


@task
def task_terraform_apply(context):
    """
    Issue a Terraform apply.
    """

    write_terraform_variables(
        terraform_variables_path=PATH_STAGING_TERRAFORM_VARIABLES,
        terraform_variables_dict={
            "name": CODEBUILD_NAME,
            "source_archive": os.path.relpath(
                PATH_STAGING_CODEBUILD_ARCHIVE, PATH_TERRAFORM_DIR
            ),
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
                        "-auto-approve",
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
            "name": CODEBUILD_NAME,
            "source_archive": os.path.relpath(
                PATH_STAGING_CODEBUILD_ARCHIVE, PATH_TERRAFORM_DIR
            ),
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


@task(pre=[task_create_codebuild_archive, task_terraform_apply, task_execute_codebuild])
def task_build(context):
    """
    Build a Docker image.
    """

    # Actual build happens in the sequence of pre-requisite tasks.
    pass


# Build task collection
ns = Collection("codebuild")

ns.add_task(task_terraform_apply, "apply")
ns.add_task(task_build, "build")
ns.add_task(task_terraform_destroy, "destroy")
