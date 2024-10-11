load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("nf.nephio.org.nfdeployments.star", "getNFDeploymentClusterID", "getNFDeploymentPartition", "getNFDeploymentName")
load("req.nephio.org.interface.star", "getNetwork", "getAttachmentType", "getIPFamilyPolicy", "getInterfaces")
load("req.kuid.dev.attachments.star", "getAttachmentReqSpec", "getAttachmentReq")

finalizer = "nf.nephio.org.nfdeployments.upf.free5gc.io.claim"
conditionType = "ClaimReady"

def reconcile(self):
  #self is nf deployment

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  itfces = ["n3", "n4", "n6", "sba"]
  interfaces, err = getInterfaces(self, itfces)
  if err != None:
    return reconcile_result(self, True, 0, conditionType, err, False)
  
  for attachementReq in getKuidAttachmentReq(self, interfaces):
    rsp = client_create(attachementReq)
    if rsp["error"] != None:
        return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])

  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)

def getKuidAttachmentReq(self, interfaces):
  attachmentReq = []
  for itfce in interfaces:
    ## only request networks/interfaces for non default network
    if getNetwork(itfce) != "default":
      attachmentReq.append(getKuidAttachmentInterfaceReq(self, itfce))
  return attachmentReq

def getKuidAttachmentInterfaceReq(self, itfce):
  clusterID = getNFDeploymentClusterID(self)

  itfceName = getName(itfce)
  nodeName = getNFDeploymentName(self)

  attachementSpec = getAttachmentReqSpec(
    itfceName,
    nodeName,
    clusterID, 
    getNetwork(itfce), 
    getIPFamilyPolicy(itfce), 
    getAttachmentType(itfce),
  )
  name = getName(self) + "." + itfceName
  return getAttachmentReq(name, getNamespace(self), attachementSpec)
