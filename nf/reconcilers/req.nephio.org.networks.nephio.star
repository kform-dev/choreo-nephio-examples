load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("req.nephio.org.interface.star", "getNetwork", "getIPFamilyPolicy", "listInterfaces")
load("req.kuid.dev.networks.star", "getNetworkReqSpec", "getNetworkReq")


finalizer = "req.nephio.org.networks.nephio"
conditionType = "Ready"

def reconcile(self):
  #self is network

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  interfaces, err = listInterfaces({})
  if err != None:
    return reconcile_result(self, True, 0, conditionType, err, False)
  
  for networkReq in getKuidNetworkReq(self, interfaces):
    rsp = client_create(networkReq)
    if rsp["error"] != None:
        return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])

  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)

def getKuidNetworkReq(self, interfaces):
  networks = {
    "default": "dual-stack",
  }
  networkReq = []
  for itfce in interfaces:
    ## only request networks/interfaces for non default network
    network = getNetwork(itfce)
    if network not in networks:
      networks[network] = getIPFamilyPolicy(itfce)
      partition = getName(self)

      networkReqSpec = getNetworkReqSpec(
        network,
        partition,
        "private",
        getIPFamilyPolicy(itfce),
      )

      name = partition + "." + network

      networkReq.append(getNetworkReq(name, getNamespace(self), networkReqSpec))
  return networkReq
  