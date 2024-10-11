load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("req.kuid.dev.prefixes.star", "setStatusPrefix")

finalizer = "req.kuid.dev.prefixes.all"
conditionType = "Ready"

def reconcile(self):
  #self is prefix req

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  if getName(self) == "nephio.vpc-internet.pool1.ipv4":
    setStatusPrefix(self, "10.0.0.0/24")
  
  return reconcile_result(self, False, 0, conditionType, "", False)
