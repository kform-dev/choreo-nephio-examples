load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("req.nephio.org.dnn.star", "getNetwork", "getPools", "getPoolName", "getPoolPrefixLength", "getPoolAddressFamilies")
load("req.kuid.dev.prefixes.star", "getPrefixReqSpec", "getPrefixReq")


finalizer = "req.nephio.org.dnns.claim"
conditionType = "ClaimReady"

def reconcile(self):
  #self is dnn

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  for prefixReq in getKuidPrefixReq(self):
    rsp = client_create(prefixReq)
    if rsp["error"] != None:
        return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])

  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)


def getKuidPrefixReq(self):
  prefixReq = []
  for pool in getPools(self):
    labels = {
      "ipam.be.kuid.dev/purpose": "dnn",
      "ipam.be.kuid.dev/poolName": getPoolName(pool),
    }

    afs = getPoolAddressFamilies(pool)

    for af in afs:
      spec = getPrefixReqSpec(
        "nephio", 
        getNetwork(self), 
        "pool", 
        getPoolPrefixLength(pool), 
        af, 
        labels,
      )
      prefixReq.append(getPrefixReq(
        "nephio" + "." + getNetwork(self) + "." + getPoolName(pool) + "." +  af,
        getNamespace(self),
        spec,
      ))
    
  return prefixReq




    
    

