def getSpec(self):
  return self.get("spec", {})

def getNetwork(self):
  spec = getSpec(self)
  return spec.get("network", "default")

def getPools(self):
  spec = getSpec(self)
  return spec.get("pools", [])

def getPoolName(pool):
  return pool.get("name", "")

def getPoolPrefixLength(pool):
  return pool.get("prefixLength", 32)

def getPoolAddressFamilies(pool):
  ipFamilyPolicy =  pool.get("ipFamilyPolicy", "dualstack")
  if ipFamilyPolicy == "dualstack":
    return ["ipv4", "ipv6"]
  elif ipFamilyPolicy == "ipv4-only":
    return ["ipv4"]
  elif ipFamilyPolicy == "ipv6-only":
    return ["ipv6"]
  else:
    return []

def getStatus(self):
  if "status" not in self:
    self["status"] = {}
  return self.get("status", {})

def getStatusPools(self):
  status = getStatus(self)
  if "pools" not in status:
    status["pools"] = []
  return status["pools"]

def getStatusPool(self, poolName):
  pools = getStatusPools(self)
  for pool in pools:
    if pool.get("name") == poolName:
      return pool
  pool = {"name": poolName}
  pools.append(pool)
  return pool

def setStatusPoolPrefix(self, poolName, af, newPrefix):
  pool = getStatusPool(self, poolName)
  if af not in pool:
    pool[af] = {"prefixes": []}

  prefixes = pool[af]["prefixes"]
  # Add the new prefix if it's not already in the list
  found = False
  for prefix in prefixes:
    if prefix["prefix"] == newPrefix:
      found = True
      break
  if not found:
      prefixes.append({"prefix": newPrefix})
  return self
