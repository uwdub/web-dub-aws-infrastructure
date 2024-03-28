import boto3
from invoke import Collection, task
import time

from tasks.constants import CODEBUILD_NAME
from tasks.terraform_codepipeline import (
    task_terraform_apply as task_terraform_codepipeline_apply,
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


@task(pre=[task_terraform_codepipeline_apply, task_execute_codebuild])
def task_build(context):
    """
    Build a Docker image.
    """

    # Actual build happens in the sequence of pre-requisite tasks.
    pass


# Build task collection
ns = Collection("codebuild")

ns.add_task(task_build, "build")
