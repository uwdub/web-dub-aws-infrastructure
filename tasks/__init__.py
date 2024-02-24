import colorama
from invoke import Collection

from tasks.collection import compose_collection
import tasks.format

# Enable color
colorama.init()

# Build our task collection
ns = Collection()

# Compose from format.py
compose_collection(ns, tasks.format.ns, sub=False)
