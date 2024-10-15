# nf example

## project folders

### crds

used to store your apis

### in

in the in folder you have 3 types of resource
- input data:
    - interface requirements
    - capacity requirements
    - nf deployments
- reconciler logic
    - business logic how to process the events
- libraries
    - supporting the reconcilers

### refs

used for upstream data/blueprints/etc

in the ref folder you have a reference to an upstream reference (e.g. an inventory blueprint)

### db 

where the choreo db is located

## start server in human dev mode

chorectl server start nf -r

## run the reconciler

chorectl run once

chorectl run diff
chorectl run diff -a

