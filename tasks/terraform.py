import json
import os
from pathlib import Path


def write_terraform_variables(
    *,
    terraform_variables_path: Path,
    terraform_variables_dict,
):
    os.makedirs(terraform_variables_path.parent, exist_ok=True)
    with open(terraform_variables_path, "w") as file_variables:
        file_variables.write(
            "\n".join(
                [
                    "################################################################################",
                    "# This file is automatically generated. Changes will be overwritten.",
                    "################################################################################",
                    "",
                ]
            )
        )
        for key, value in terraform_variables_dict.items():
            file_variables.write(
                "{} = {}\n".format(
                    key,
                    json.dumps(value, separators=(",", " = ")),
                )
            )
