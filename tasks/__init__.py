import colorama
from invoke import Collection

from tasks.collection import compose_collection

import tasks.aws
import tasks.codebuild
import tasks.format
import tasks.terraform_backend
import tasks.terraform_codepipeline
import tasks.terraform_ecr

# Enable color
colorama.init()

# Apply AWS environment
tasks.aws.apply_aws_env()

# Build our task collection
ns = Collection()

# Compose from codebuild.py
compose_collection(
    ns,
    tasks.codebuild.ns,
    name="codebuild",
    include=["build"],
)

# Compose from format.py
compose_collection(
    ns,
    tasks.format.ns,
    sub=False,
)

# Compose Terraform tasks
ns_terraform = Collection("terraform")

# Compose from codebuild.py
compose_collection(
    ns_terraform,
    tasks.codebuild.ns,
    name="codebuild",
    include=["destroy"],
)

# Compose from codepipeline.py
compose_collection(ns_terraform, tasks.terraform_codepipeline.ns, name="codepipeline")

# Complete Terraform tasks
compose_collection(
    ns,
    ns_terraform,
    name="terraform",
)

#
# Additional non-needed tasks.
#

# Compose from aws.py
# Needed only for initial AWS configuration.
# compose_collection(ns, tasks.aws.ns, name="aws")

# Compose from codebuild.py
# Needed only if we needed to access apply without triggering a build.
# compose_collection(ns_terraform, tasks.codebuild.ns, name="codebuild", include=["apply"])
# compose_collection(ns, ns_terraform, name="terraform")

# Compose from terraform_backend.py
# Needed only for initial backend configuration.
# compose_collection(ns_terraform, tasks.terraform_backend.ns, name="backend")
# compose_collection(ns, ns_terraform, name="terraform")

# Compose from terraform_ecr.py
# Needed only for initial creation.
# compose_collection(ns_terraform, tasks.terraform_ecr.ns, name="ecr")
# compose_collection(ns, ns_terraform, name="terraform")
