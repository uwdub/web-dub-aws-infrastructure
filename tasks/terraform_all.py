from invoke import Collection, task

import tasks.terraform_alb
import tasks.terraform_backend
import tasks.terraform_codepipeline
import tasks.terraform_ecr
import tasks.terraform_ecs
import tasks.terraform_network

TASK_ORDER = [
    tasks.terraform_backend.task_terraform_apply,
    tasks.terraform_ecr.task_terraform_apply,
    tasks.terraform_network.task_terraform_apply,
    tasks.terraform_alb.task_terraform_apply,
    tasks.terraform_codepipeline.task_terraform_apply,
    tasks.terraform_ecs.task_terraform_apply,
]


@task(pre=TASK_ORDER)
def task_terraform_apply(context):
    """
    Issue all Terraform apply.
    """
    pass


@task(pre=reversed(TASK_ORDER))
def task_terraform_destroy(context):
    """
    Issue all Terraform destroy.
    """
    pass


# Build task collection
ns = Collection("all")

ns.add_task(task_terraform_apply, "apply")
ns.add_task(task_terraform_destroy, "destroy")