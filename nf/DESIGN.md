# Design

TODO:
- capacity: easy
- dnn: easy
- parameterRef: easy

##

network controller
- condition: Ready
- for network
- creates
    - network req

dnn controller
- condition: DNNReady
- for dnn
- creates
    - prefix req

nf controller (claims)
- condition: ClaimReady
- for nfdeployment based per provider
- reads the interface reqs 
    - upf:
        - n3, n4, n6, sba
    - smf:
        - n4, n11, sba
    - amf:
        - n2, sba 
- creates:
    - attachment requests
    - SetClaimReady False

req.kuid.dev reconcilers
    - 

nfcontroller (ready)
- condition: Ready
- for nfdeployment based per provider + ClaimReady 
- look at amf request
condition
- reads the NFConfigs
- 