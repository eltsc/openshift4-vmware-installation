#! /bin/bash

set -x

oc delete dc confluence

oc delete pvc pvc-confluence
