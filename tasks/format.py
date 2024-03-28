"""
Task for applying code formatting.
"""

from invoke import Collection, task


@task
def task_format(context):
    """
    Apply code formatting.
    """

    context.run(
        command=" ".join(
            [
                "pipenv",
                "run",
                "black",
                ".",
            ]
        ),
    )


# Build task collection
ns = Collection("format")

ns.add_task(task_format, "format")
