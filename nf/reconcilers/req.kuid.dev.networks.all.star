load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("req.kuid.dev.networks.star", "getSpecName", "setStatusName")

finalizer = "req.kuid.dev.networks.all"
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

  setStatusName(self, getSpecName(self))
  
  return reconcile_result(self, False, 0, conditionType, "", False)
