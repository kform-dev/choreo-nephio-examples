load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer", "getUID")
load("req.nephio.org.dnn.star", "getNetwork", "getPools", "getPoolName", "getPoolPrefixLength", "setStatusPoolPrefix")
load("req.kuid.dev.prefixes.star", "getPrefixReqSpec", "getPrefixReq", "listReadyPrefixRequests", "getAddressFamily", "getStatusPrefix", "getSpecLabels")


finalizer = "req.nephio.org.dnns.ready"
conditionType = "Ready"

def reconcile(self):
  #self is dnn

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  prefixRequests, ready, err = listReadyPrefixRequests({}, getUID(self))
  if err != None:
    return reconcile_result(self, False, 0, conditionType, err, False)
  
  if not ready:
    return reconcile_result(self, False, 0, conditionType, "prefix req not ready", False)

  for prefixRequest in prefixRequests:
    af = getAddressFamily(prefixRequest)
    prefix = getStatusPrefix(prefixRequest)

    labels = getSpecLabels(prefixRequest)
    poolName = labels.get("ipam.be.kuid.dev/poolName", "")
    setStatusPoolPrefix(self, poolName, af, prefix)
    
  
  return reconcile_result(self, False, 0, conditionType, "", False)


