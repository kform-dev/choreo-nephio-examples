load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer", "getUID")
load("nf.nephio.org.nfdeployments.star", "getSpec", "getNFDeploymentClusterID", "getNFDeploymentPartition", "getNFDeploymentName")
load("req.nephio.org.interface.star", "getNetwork", "getAttachmentType", "getIPFamilyPolicy", "getInterfaces")
load("req.kuid.dev.attachments.star", "getAttachmentReqSpec", "getAttachmentReq", "listReadyAttachmentRequests", "getSpecInterface", "getSpecNetwork", "getStatusPrefixPerAF")

finalizer = "nf.nephio.org.nfdeployments.upf.free5gc.io.ready"
conditionType = "Ready"

def reconcile(self):
  #self is nf deployment

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  attachmentRequests, ready, err = listReadyAttachmentRequests({}, getUID(self))
  if err != None:
    return reconcile_result(self, False, 0, conditionType, err, False)
  
  if not ready:
    return reconcile_result(self, False, 0, conditionType, "prefix req not ready", False)
    
  afs = ["ipv4", "ipv6"]
  interfaces = []
  networks = []
  for attachementReq in attachmentRequests:
    ifName = getSpecInterface(attachementReq)
    networkName = getSpecNetwork(attachementReq)
    network, networkExists =  getLocalNetwork(networks, networkName)
    networkInterfaces = network.get("interfaces", [])
    networkInterfaces.append(ifName)
    
    interfaceConfig = {"name": ifName}
    for af in afs:
      prefixes = getStatusPrefixPerAF(attachementReq, af)
      if len(prefixes) > 0:
        interfaceConfig[af] = {"address": prefixes[0]["prefix"]}
        if prefixes[0]["defaultGateway"] != None:
          interfaceConfig[af]["gateway"] = prefixes[0]["defaultGateway"]
    interfaces.append(interfaceConfig)
    if not networkExists:
      networks.append(network)
  
  spec = getSpec(self)
  spec["interfaces"] = interfaces
  spec["networkInstances"] = networks

  return reconcile_result(self, False, 0, conditionType, "", False)


def getLocalNetwork(networks, networkName):
  for network in networks:
    if network.get("name", "") == networkName:
      return network, True
  return {"name": networkName, "interfaces": []}, False